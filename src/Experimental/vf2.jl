"""
    VF2

An empty concrete type used to dispatch to [`vf2`](@ref) isomorphism functions.
"""
struct VF2 <: IsomorphismAlgorithm end

"""
    VF2State{G, T}

Structure that is internally used by vf2
"""
struct VF2State{G, T}
    g1::G
    g2::G
    core_1::Vector{T}
    core_2::Vector{T}
    in_1::Vector{T}
    in_2::Vector{T}
    out_1::Vector{T}
    out_2::Vector{T}

    function VF2State(g1::G, g2::G) where {G <: AbstractSimpleGraph{T}} where {T <: Integer}
        n1 = nv(g1)
        n2 = nv(g2)
        core_1 = zeros(T, n1)
        core_2 = zeros(T, n2)
        in_1 = zeros(T, n1)
        in_2 = zeros(T, n2)
        out_1 = zeros(T, n1)
        out_2 = zeros(T, n2)

        return new{G, T}(g1, g2, core_1, core_2, in_1, in_2, out_1, out_2)
    end
end

"""
    vf2(callback, g1, g2, problemtype; vertex_relation=nothing, edge_relation=nothing)

Iterate over all isomorphism between the graphs `g1` (or subgraphs thereof) and `g2`.
The problem that is solved depends on the value of `problemtype`:
- IsomorphismProblem(): Only isomorphisms between the whole graph `g1` and `g2` are considered.
- SubGraphIsomorphismProblem(): All isomorphism between subgraphs of `g1` and `g2` are considered.
- InducedSubGraphIsomorphismProblem(): All isomorphism between vertex induced subgraphs of `g1` and `g2` are considered.

Upon finding an isomorphism, the function `callback` is called with a vector `vmap` as an argument.
`vmap` is a vector where `vmap[v] == u` means that vertex `v` in `g2` is mapped to vertex `u` in `g1`.
If the algorithm should look for another isomorphism, then this function should return `true`.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### References
Luigi P. Cordella, Pasquale Foggia, Carlo Sansone, Mario Vento
“A (Sub)Graph Isomorphism Algorithm for Matching Large Graphs”
"""
function vf2(callback::Function, g1::G, g2::G, problemtype::GraphMorphismProblem; 
             vertex_relation::Union{Nothing, Function}=nothing, 
             edge_relation::Union{Nothing, Function}=nothing) where {G <: AbstractSimpleGraph}
    if nv(g1) < nv(g2) || (problemtype == IsomorphismProblem() && nv(g1) != nv(g2))
        return 
    end

    start_state = VF2State(g1, g2)
    start_depth = 1
    vf2match!(start_state, start_depth, callback, problemtype, vertex_relation, edge_relation)
    return
end

"""
    vf2check_feasibility(u, v, state, problemtype, vertex_relation, edge_relation)

Check whether two vertices of G₁ and G₂ can be matched. Used by [`vf2match!`](@ref).
"""
function vf2check_feasibility(u, v, state::VF2State, problemtype,
                              vertex_relation::Union{Nothing, Function},
                              edge_relation::Union{Nothing, Function})
    @inline function vf2rule_pred(u, v, state::VF2State, problemtype)
        if problemtype != SubGraphIsomorphismProblem()
            @inbounds for u2 in inneighbors(state.g1, u)
                if state.core_1[u2] != 0
                    found = false
                    # TODO can probably be replaced with has_edge for better performance
                    for v2 in inneighbors(state.g2, v)
                        if state.core_1[u2] == v2
                            found = true
                            break
                        end
                    end
                    found || return false
                end
            end
        end
        @inbounds for v2 in inneighbors(state.g2, v)
            if state.core_2[v2] != 0
                found = false
                for u2 in inneighbors(state.g1, u)
                    if state.core_2[v2] == u2
                        found = true
                        break
                    end
                end
                found || return false
            end
        end
        return true
    end

    @inline function vf2rule_succ(u, v, state::VF2State, problemtype)
        if problemtype != SubGraphIsomorphismProblem()
            @inbounds for u2 in outneighbors(state.g1, u)
                if state.core_1[u2] != 0
                    found = false
                    for v2 in outneighbors(state.g2, v)
                        if state.core_1[u2] == v2
                            found = true
                            break
                        end
                    end
                    found || return false
                end
            end
        end
        found = false
        @inbounds for v2 in outneighbors(state.g2, v)
            if state.core_2[v2] != 0
                found = false
                for u2 in outneighbors(state.g1, u)
                    if state.core_2[v2] == u2
                        found = true
                        break
                    end
                end
                found || return false
            end
        end
        return true
    end
    

    @inline function vf2rule_in(u, v, state::VF2State, problemtype)
        count1 = 0
        count2 = 0
        @inbounds for u2 in outneighbors(state.g1, u)
            if state.in_1[u2] != 0 && state.core_1[u2] == 0
                count1 += 1
            end
        end
        @inbounds for v2 in outneighbors(state.g2, v)
            if state.in_2[v2] != 0 && state.core_2[v2] == 0
                count2 += 1
            end
        end
        if problemtype == IsomorphismProblem()
            count1 == count2 || return false
        else
            count1 >= count2 || return false
        end
        count1 = 0
        count2 = 0
        @inbounds for u2 in inneighbors(state.g1, u)
            if state.in_1[u2] != 0 && state.core_1[u2] == 0
                count1 += 1
            end
        end
        @inbounds for v2 in inneighbors(state.g2, v)
            if state.in_2[v2] != 0 && state.core_2[v2] == 0
                count2 += 1
            end
        end
        problemtype == IsomorphismProblem() && return count1 == count2   

        return count1 >= count2   
    end

    @inline function vf2rule_out(u, v, state::VF2State, problemtype)
        count1 = 0
        count2 = 0
        @inbounds for u2 in outneighbors(state.g1, u)
            if state.out_1[u2] != 0 && state.core_1[u2] == 0
                count1 += 1
            end
        end
        @inbounds for v2 in outneighbors(state.g2, v)
            if state.out_2[v2] != 0 && state.core_2[v2] == 0
                count2 += 1
            end
        end
        if problemtype == IsomorphismProblem()
            count1 == count2 || return false
        else
            count1 >= count2 || return false
        end

        count1 = 0
        count2 = 0
        @inbounds for u2 in inneighbors(state.g1, u)
            if state.out_1[u2] != 0 && state.core_1[u2] == 0
                count1 += 1
            end
        end
        @inbounds for v2 in inneighbors(state.g2, v)
            if state.out_2[v2] != 0 && state.core_2[v2] == 0
                count2 += 1
            end
        end
        problemtype == IsomorphismProblem() && return count1 == count2   

        return count1 >= count2   
    end

    @inline function vf2rule_new(u, v, state::VF2State, problemtype)
        problemtype == SubGraphIsomorphismProblem() && return true
        count1 = 0
        count2 = 0
        @inbounds for u2 in inneighbors(state.g1, u)
            if state.in_1[u2] == 0 && state.out_1[u2] == 0
                count1 += 1
            end
        end
        @inbounds for v2 in inneighbors(state.g2, v)
            if state.in_2[v2] == 0 && state.out_2[v2] == 0
                count2 += 1
            end
        end
        if problemtype == IsomorphismProblem()
            count1 == count2 || return false
        else
            count1 >= count2 || return false
        end
        count1 = 0
        count2 = 0
        @inbounds for u2 in outneighbors(state.g1, u)
            if state.in_1[u2] == 0 && state.out_1[u2] == 0
                count1 += 1
            end
        end
        @inbounds for v2 in outneighbors(state.g2, v)
            if state.in_2[v2] == 0 && state.out_2[v2] == 0
                count2 += 1
            end
        end
        problemtype == IsomorphismProblem() && return count1 == count2   
    
        return count1 >= count2
    end

    @inline function vf2rule_self_loops(u, v, state, problemtype)
        u_selflooped = has_edge(state.g1, u, u)
        v_selflooped = has_edge(state.g2, v, v)

        if problemtype == SubGraphIsomorphismProblem()
            return u_selflooped || !v_selflooped
        end
        return u_selflooped == v_selflooped
    end

    syntactic_feasability = vf2rule_pred(u, v, state, problemtype) && 
                            vf2rule_succ(u, v, state, problemtype) && 
                            vf2rule_in(u, v, state, problemtype)   && 
                            vf2rule_out(u, v, state, problemtype)  && 
                            vf2rule_new(u, v, state, problemtype)  &&
                            vf2rule_self_loops(u, v, state, problemtype)
    syntactic_feasability || return false


    if vertex_relation != nothing
        vertex_relation(u, v) || return false
    end
    if edge_relation != nothing
        E1 = edgetype(state.g1)
        E2 = edgetype(state.g2)
        for u2 in outneighbors(state.g1, u)
            state.core_1[u2] == 0 && continue
            v2 = state.core_1[u2]
            edge_relation(E1(u, u2), E2(v, v2)) || return false
        end
        for u2 in inneighbors(state.g1, u)
            state.core_1[u2] == 0 && continue
            v2 = state.core_1[u2]
            edge_relation(E1(u2, u), E2(v2, v)) || return false
        end
    end
    return true
end

"""
    vf2update_state!(state, u, v, depth)

Update state before recursing. Helper function for [`vf2match!`](@ref).
"""
function vf2update_state!(state::VF2State, u, v, depth)
@inbounds begin
     state.core_1[u] = v
     state.core_2[v] = u
     for w in outneighbors(state.g1, u)
         if state.out_1[w] == 0
             state.out_1[w] = depth
         end
     end
     for w in inneighbors(state.g1, u)
         if state.in_1[w] == 0
             state.in_1[w] = depth
         end
     end
     for w in outneighbors(state.g2, v)
         if state.out_2[w] == 0
             state.out_2[w] = depth
         end
     end
     for w in inneighbors(state.g2, v)
         if state.in_2[w] == 0
             state.in_2[w] = depth
         end
     end
end
end

"""
    vf2reset_state!(state, u, v, depth)

Reset state after returning from recursion. Helper function for [`vf2match!`](@ref).
"""
function vf2reset_state!(state::VF2State, u, v, depth)
@inbounds begin
    state.core_1[u] = 0
    state.core_2[v] = 0
    for w in outneighbors(state.g1, u)
        if state.out_1[w] == depth
            state.out_1[w] = 0
        end
    end
    for w in inneighbors(state.g1, u)
        if state.in_1[w] == depth
            state.in_1[w] = 0
        end
    end
    for w in outneighbors(state.g2, v)
        if state.out_2[w] == depth
            state.out_2[w] = 0
        end
    end
    for w in inneighbors(state.g2, v)
        if state.in_2[w] == depth
            state.in_2[w] = 0
        end
    end
end
end

"""
    vf2match!(state, depth, callback, problemtype, vertex_relation, edge_relation)

Perform isomorphic subgraph matching. Called by [`vf2`](@ref).
"""
function vf2match!(state, depth, callback::Function, problemtype::GraphMorphismProblem,
                   vertex_relation, edge_relation)
    n1 = Int(nv(state.g1))
    n2 = Int(nv(state.g2))
    # if all vertices of G₂ are matched we call the callback function. If the
    # algorithm should look for another isomorphism then callback has to return true
    if depth > n2
        keepgoing = callback(state.core_2)
        return keepgoing
    end
    # First we try if there is a pair of unmatched vertices u∈G₁ v∈G₂ that are connected
    # by an edge going out of the set M(s) of already matched vertices
    found_pair = false
    v = 0
    @inbounds for j = 1:n2
        if state.out_2[j] != 0 && state.core_2[j] == 0
            v = j
            break
        end
    end
    if v != 0
        @inbounds for u = 1:n1
            if state.out_1[u] != 0 && state.core_1[u] == 0
                found_pair = true
                if vf2check_feasibility(u, v, state, problemtype, vertex_relation, edge_relation)
                    vf2update_state!(state, u, v, depth)
                    keepgoing = vf2match!(state, depth + 1, callback, problemtype, 
                                          vertex_relation, edge_relation) 
                    keepgoing || return false
                    vf2reset_state!(state, u, v, depth)
                end
            end
        end
    end
    found_pair && return true
    # If that is not the case we try if there is a pair of unmatched vertices u∈G₁ v∈G₂ that 
    # are connected  by an edge coming in from the set M(s) of already matched vertices
    v = 0
    @inbounds for j = 1:n2
        if state.in_2[j] != 0 && state.core_2[j] == 0
            v = j
            break
        end
    end
    if v != 0
        @inbounds for u = 1:n1
            if state.in_1[u] != 0 && state.core_1[u] == 0
                found_pair = true
                if vf2check_feasibility(u, v, state, problemtype, vertex_relation, edge_relation)
                    vf2update_state!(state, u, v, depth)
                    keepgoing = vf2match!(state, depth + 1, callback, problemtype,
                                          vertex_relation, edge_relation) 
                    keepgoing || return false
                    vf2reset_state!(state, u, v, depth)
                end
            end
        end
    end
    found_pair && return true
    # If this is also not the case, we try all pairs of vertices u∈G₁ v∈G₂ that are not
    # yet matched
    v = 0
    @inbounds for j = 1:n2
        if state.core_2[j] == 0
            v = j
            break
        end
    end
    if v != 0
        @inbounds for u = 1:n1
            if state.core_1[u] == 0
                if vf2check_feasibility(u, v, state, problemtype, vertex_relation, edge_relation)
                    vf2update_state!(state, u, v, depth)
                    keepgoing = vf2match!(state, depth + 1, callback, problemtype,
                                          vertex_relation, edge_relation) 
                    keepgoing || return false
                    vf2reset_state!(state, u, v, depth)
                end
            end
        end    
    end
    return true
end


function has_induced_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                                 vertex_relation::Union{Nothing, Function}=nothing,
                                 edge_relation::Union{Nothing, Function}=nothing)::Bool
        result = false
        callback(vmap) = (result = true; return false)
        vf2(callback, g1, g2, InducedSubGraphIsomorphismProblem();
                       vertex_relation=vertex_relation, edge_relation=edge_relation)
        return result
end

function has_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                                 vertex_relation::Union{Nothing, Function}=nothing,
                                 edge_relation::Union{Nothing, Function}=nothing,)::Bool
    result = false
    callback(vmap) = (result = true; return false)
    vf2(callback, g1, g2, SubGraphIsomorphismProblem();
        vertex_relation=vertex_relation, edge_relation=edge_relation)
    return result
end

function has_isomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                         vertex_relation::Union{Nothing, Function}=nothing,
                         edge_relation::Union{Nothing, Function}=nothing)::Bool

    !could_have_isomorph(g1, g2) && return false

    result = false
    callback(vmap) = (result = true; return false)
    vf2(callback, g1, g2, IsomorphismProblem(),
        vertex_relation=vertex_relation,
        edge_relation=edge_relation)
    return result
end

function count_induced_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                                   vertex_relation::Union{Nothing, Function}=nothing,
                                   edge_relation::Union{Nothing, Function}=nothing)::Int
    result = 0
    callback(vmap) = (result += 1; return true)
    vf2(callback, g1, g2, InducedSubGraphIsomorphismProblem(),
        vertex_relation=vertex_relation,
        edge_relation=edge_relation)
    return result
end

function count_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                                vertex_relation::Union{Nothing, Function}=nothing,
                                edge_relation::Union{Nothing, Function}=nothing)::Int
    result = 0
    callback(vmap) = (result += 1; return true)
    vf2(callback, g1, g2, SubGraphIsomorphismProblem(), vertex_relation=vertex_relation, edge_relation=edge_relation)
    return result
end

function count_isomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                        vertex_relation::Union{Nothing, Function}=nothing,
                        edge_relation::Union{Nothing, Function}=nothing)::Int
    !could_have_isomorph(g1, g2) && return 0
    result = 0
    callback(vmap) = (result += 1; return true)
    vf2(callback, g1, g2, IsomorphismProblem(), vertex_relation=vertex_relation, edge_relation=edge_relation)
    return result
end

function all_induced_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                                 vertex_relation::Union{Nothing, Function}=nothing,
                                 edge_relation::Union{Nothing, Function}=nothing)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
        make_callback(c) = vmap -> (put!(c, collect(zip(vmap,1:length(vmap)))), return true)
    T = Vector{Tuple{eltype(g1), eltype(g2)}}
    ch::Channel{T} = Channel(ctype=T) do c
        vf2(make_callback(c), g1, g2, InducedSubGraphIsomorphismProblem(), 
                       vertex_relation=vertex_relation,
                       edge_relation=edge_relation)
    end
end

function all_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                              vertex_relation::Union{Nothing, Function}=nothing,
                              edge_relation::Union{Nothing, Function}=nothing)::Channel{Vector{Tuple{eltype(g1), eltype(g2)}}}

    make_callback(c) = vmap -> (put!(c, collect(zip(vmap,1:length(vmap)))), return true)
    T = Vector{Tuple{eltype(g1), eltype(g2)}}
    ch::Channel{T} = Channel(ctype=T) do c
        vf2(make_callback(c), g1, g2, SubGraphIsomorphismProblem(), 
            vertex_relation=vertex_relation,
            edge_relation=edge_relation)
    end
    return ch
end

function all_isomorph(g1::AbstractGraph, g2::AbstractGraph, alg::VF2;
                 vertex_relation::Union{Nothing, Function}=nothing,
                 edge_relation::Union{Nothing, Function}=nothing)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    T = Vector{Tuple{eltype(g1), eltype(g2)}}
    !could_have_isomorph(g1, g2) && return Channel(_ -> return, ctype=T)
    make_callback(c) = vmap -> (put!(c, collect(zip(vmap,1:length(vmap)))), return true)
    ch::Channel{T} = Channel(ctype=T) do c
        vf2(make_callback(c), g1, g2, IsomorphismProblem(), 
            vertex_relation=vertex_relation,
            edge_relation=edge_relation)
    end
    return ch
end
