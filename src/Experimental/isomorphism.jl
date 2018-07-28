abstract type GraphMorphismProblemType end
struct IsomorphismProblemType <: GraphMorphismProblemType end
struct SubGraphIsomorphismProblemType <: GraphMorphismProblemType end
struct InducedSubGraphIsomorphismProblemType <: GraphMorphismProblemType end

const IsomorphismProblem = IsomorphismProblemType()
const SubGraphIsomorphismProblem = SubGraphIsomorphismProblemType()
const InducedSubGraphIsomorphismProblem = InducedSubGraphIsomorphismProblemType()

"""
    has_induced_subgraphiso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns `true` if the graph `g1` contains a vertex induced subgraph that is isomorphic to `g2`.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> has_induced_subgraphiso(CompleteGraph(5), CompleteGraph(4))
true
julia> has_induced_subgraphiso(CompleteGraph(5), CycleGraph(4))
false

julia> g1 = PathDiGraph(3); color1 = [1, 1, 1]
julia> g2 = PathDiGraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> has_induced_subgraphiso(g1, g2)
true
julia> has_induced_subgraphiso(g1, g2, vertex_relation=color_rel)
false
```
### See also 
[`has_subgraphiso`](@ref), [`has_iso`](@ref), [`count_induced_subgraphiso`](@ref), [`all_induced_subgraphiso`](@ref)
"""
function has_induced_subgraphiso(g1::AbstractGraph, g2::AbstractGraph;
                                 vertex_relation::Union{Nothing, Function}=nothing,
                                 edge_relation::Union{Nothing, Function}=nothing,
                                 alg=:vf2)::Bool
    if alg == :vf2
        result = false
        callback(vmap) = (result = true; return false)
        vf2(callback, g1, g2, InducedSubGraphIsomorphismProblem;
                       vertex_relation=vertex_relation, edge_relation=edge_relation)
        return result
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

"""
    has_subgraphiso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns `true` if the graph `g1` contains a subgraph that is isomorphic to `g2`.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> has_subgraphiso(CompleteGraph(5), CompleteGraph(4))
true
julia> has_subgraphiso(CompleteGraph(5), CycleGraph(4))
true

julia> g1 = PathDiGraph(3); color1 = [1, 1, 1]
julia> g2 = PathDiGraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> has_subgraphiso(g1, g2)
true
julia> has_subgraphiso(g1, g2, vertex_relation=color_rel)
false
```
### See also 
[`has_induced_subgraphiso`](@ref), [`has_iso`](@ref), [`count_subgraphiso`](@ref), [`all_subgraphiso`](@ref)
"""
function has_subgraphiso(g1::AbstractGraph, g2::AbstractGraph;
                                 vertex_relation::Union{Nothing, Function}=nothing,
                                 edge_relation::Union{Nothing, Function}=nothing,
                                alg=:vf2)::Bool
    if alg == :vf2
        result = false
        callback(vmap) = (result = true; return false)
        vf2(callback, g1, g2, SubGraphIsomorphismProblem;
                       vertex_relation=vertex_relation, edge_relation=edge_relation)
        return result
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

"""
    has_iso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns `true` if the graph `g1` is isomorphic to `g2`.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> has_iso(CompleteGraph(3), CycleGraph(3))
true
julia> has_iso(CompleteGraph(4), CycleGraph(4))
false

julia> g1 = PathDiGraph(4); color1 = [1, 2, 1, 1]
julia> g2 = PathDiGraph(4); color2 = [1, 2, 2, 1]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> has_iso(g1, g2)
true
julia> has_iso(g1, g2, vertex_relation=color_rel)
false
```
### See also 
[`has_induced_subgraphiso`](@ref), [`has_subgraphiso`](@ref), [`count_subgraphiso`](@ref), [`all_subgraphiso`](@ref)
"""
function has_iso(g1::AbstractGraph, g2::AbstractGraph;
                         vertex_relation::Union{Nothing, Function}=nothing,
                         edge_relation::Union{Nothing, Function}=nothing,
                         alg=:vf2)::Bool
    if alg == :vf2
        result = false
        callback(vmap) = (result = true; return false)
        vf2(callback, g1, g2, IsomorphismProblem,
                       vertex_relation=vertex_relation,
                       edge_relation=edge_relation)
        return result
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

"""
    count_induced_subgraphiso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns the number of vertex induced subgraphs of the graph `g1` that are isomorphic to `g2`.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> count_induced_subgraphiso(CompleteGraph(5), CompleteGraph(4))
120
julia> count_induced_subgraphiso(CompleteGraph(5), CycleGraph(4))
0

julia> g1 = PathGraph(3); color1 = [1, 1, 2]
julia> g2 = PathGraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> count_induced_subgraphiso(g1, g2)
2
julia> count_induced_subgraphiso(g1, g2, vertex_relation=color_rel)
1
```
### See also 
[`count_subgraphiso`](@ref), [`count_iso`](@ref), [`has_induced_subgraphiso`](@ref), [`all_induced_subgraphiso`](@ref)
"""
function count_induced_subgraphiso(g1::AbstractGraph, g2::AbstractGraph;
                                   vertex_relation::Union{Nothing, Function}=nothing,
                                   edge_relation::Union{Nothing, Function}=nothing,
                                   alg=:vf2)::Int
    if alg == :vf2
        result = 0
        callback(vmap) = (result += 1; return true)
        vf2(callback, g1, g2, InducedSubGraphIsomorphismProblem,
                       vertex_relation=vertex_relation,
                       edge_relation=edge_relation)
        return result
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

"""
    count_subgraphiso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns the number of subgraphs of the graph `g1` that are isomorphic to `g2`.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> count_subgraphiso(CompleteGraph(5), CompleteGraph(4))
120
julia> count_subgraphiso(CompleteGraph(5), CycleGraph(4))
120

julia> g1 = CycleDiGraph(3); color1 = [1, 1, 2]
julia> g2 = SimpleDiGraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> count_subgraphiso(g1, g2)
6
julia> count_subgraphiso(g1, g2, vertex_relation=color_rel)
2
```
### See also 
[`count_induced_subgraphiso`](@ref), [`count_iso`](@ref), [`has_subgraphiso`](@ref), [`all_subgraphiso`](@ref)
"""
function count_subgraphiso(g1::AbstractGraph, g2::AbstractGraph;
                                   vertex_relation::Union{Nothing, Function}=nothing,
                                   edge_relation::Union{Nothing, Function}=nothing,
                                   alg=:vf2)::Int
    if alg == :vf2
        result = 0
        callback(vmap) = (result += 1; return true)
        vf2(callback, g1, g2, SubGraphIsomorphismProblem, vertex_relation=vertex_relation, edge_relation=edge_relation)
        return result
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

"""
    count_iso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns the number of isomorphism from graph `g1` to `g2`.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> count_iso(CycleGraph(5), CycleGraph(5))
10
julia> count_iso(CompleteGraph(5), CycleGraph(5))
0

julia> g1 = CycleDiGraph(3); color1 = [1, 1, 2]
julia> g2 = CycleDiGraph(3); color2 = [1, 1, 1]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> count_iso(g1, g2)
3
julia> count_iso(g1, g2, vertex_relation=color_rel)
0
```
### See also 
[`count_induced_subgraphiso`](@ref), [`count_subgraphiso`](@ref), [`has_iso`](@ref), [`all_iso`](@ref)
"""
function count_iso(g1::AbstractGraph, g2::AbstractGraph;
                           vertex_relation::Union{Nothing, Function}=nothing,
                           edge_relation::Union{Nothing, Function}=nothing,
                           alg=:vf2)::Int
    if alg == :vf2
        result = 0
        callback(vmap) = (result += 1; return true)
        vf2(callback, g1, g2, IsomorphismProblem, vertex_relation=vertex_relation, edge_relation=edge_relation)
        return result
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

"""
    all_induced_subgraphiso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns all isomoprhism from vertex induced subgraphs of  `g1` to `g2`.
The isomorphisms are returned as an iterator of vectors of tuples, where the i-th vector is 
the i-th isomorphism and a tuple (u, v) in this vector means that u ∈ g1 is
mapped to v ∈ g2.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> all_induced_subgraphiso(PathGraph(3), SimpleGraph(2)) |> collect
2-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (3, 2)]
 [(3, 1), (1, 2)]

julia> g1 = PathDiGraph(3); color1 = [1, 1, 2]
julia> g2 = PathDiGraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> all_induced_subgraphiso(g1, g2) |> collect
2-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
 [(2, 1), (3, 2)]
julia> all_induced_subgraphiso(g1, g2, vertex_relation=color_rel) |> collect
1-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
```
### See also 
[`all_subgraphiso`](@ref), [`all_iso`](@ref), [`has_induced_subgraphiso`](@ref), [`count_induced_subgraphiso`](@ref)
"""
function all_induced_subgraphiso(g1::AbstractGraph, g2::AbstractGraph;
                                 vertex_relation::Union{Nothing, Function}=nothing,
                                 edge_relation::Union{Nothing, Function}=nothing,
                                 alg=:vf2)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    if alg == :vf2
        make_callback(c) = vmap -> (put!(c, collect(zip(vmap,1:length(vmap)))), return true)
        T = Vector{Tuple{eltype(g1), eltype(g2)}}
        ch::Channel{T} = Channel(ctype=T) do c
            vf2(make_callback(c), g1, g2, InducedSubGraphIsomorphismProblem, 
                           vertex_relation=vertex_relation,
                           edge_relation=edge_relation)
        end
        return ch
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

"""
    all_subgraphiso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns all isomorphism from  subgraphs of  `g1` to `g2`.
The isomorphisms are returned as an iterator of vectors of tuples, where the i-th vector is 
the i-th isomorphism and a tuple (u, v) in this vector means that u ∈ g1 is
mapped to v ∈ g2.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> all_subgraphiso(PathGraph(3), PathGraph(2)) |> collect
4-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
 [(2, 1), (1, 2)]
 [(2, 1), (3, 2)]
 [(3, 1), (2, 2)]

julia> g1 = PathDiGraph(3); color1 = [1, 1, 2]
julia> g2 = PathDiGraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> all_subgraphiso(g1, g2) |> collect
2-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
 [(2, 1), (3, 2)]
julia> all_subgraphiso(g1, g2, vertex_relation=color_rel)
1-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(2, 1), (3, 2)]
```
### See also 
[`all_induced_subgraphiso`](@ref), [`all_iso`](@ref), [`has_subgraphiso`](@ref), [`count_subgraphiso`](@ref)
"""
function all_subgraphiso(g1::AbstractGraph, g2::AbstractGraph;
                         vertex_relation::Union{Nothing, Function}=nothing,
                         edge_relation::Union{Nothing, Function}=nothing,
                         alg=:vf2)::Channel{Vector{Tuple{eltype(g1), eltype(g2)}}}

    if alg == :vf2
        make_callback(c) = vmap -> (put!(c, collect(zip(vmap,1:length(vmap)))), return true)
        T = Vector{Tuple{eltype(g1), eltype(g2)}}
        ch::Channel{T} = Channel(ctype=T) do c
            vf2(make_callback(c), g1, g2, SubGraphIsomorphismProblem, 
                           vertex_relation=vertex_relation,
                           edge_relation=edge_relation)
        end
        return ch
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

"""
    all_iso(g1, g2; vertex_relation=nothing, edge_relation=nothing, alg=:vf2)

Returns all isomorphism from `g1` to `g2`.
The isomorphisms are returned as an iterator of vectors of tuples, where the i-th vector is 
the i-th isomorphism and a tuple (u, v) in this vector means that u ∈ g1 is
mapped to v ∈ g2.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `:vf2` at the moment.

### Examples
```doctest.jl
julia> all_iso(StarGraph(4), StarGraph(4)) |> collect
6-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2), (3, 3), (4, 4)]
 [(1, 1), (2, 2), (4, 3), (3, 4)]
 [(1, 1), (3, 2), (2, 3), (4, 4)]
 [(1, 1), (3, 2), (4, 3), (2, 4)]
 [(1, 1), (4, 2), (2, 3), (3, 4)]
 [(1, 1), (4, 2), (3, 3), (2, 4)]
 
julia> g1 = CycleDiGraph(3); color1 = [1, 1, 2]
julia> g2 = CycleDiGraph(3); color2 = [2, 1, 1]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> all_iso(g1, g2) |> collect
3-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2), (3, 3)]
 [(2, 1), (3, 2), (1, 3)]
 [(3, 1), (1, 2), (2, 3)]
julia> all_subgraphiso(g1, g2, vertex_relation=color_rel)
1-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(3, 1), (1, 2), (2, 3)]
```
### See also 
[`all_induced_subgraphiso`](@ref), [`all_subgraphiso`](@ref), [`has_iso`](@ref), [`count_iso`](@ref)
"""
function all_iso(g1::AbstractGraph, g2::AbstractGraph;
                 vertex_relation::Union{Nothing, Function}=nothing,
                 edge_relation::Union{Nothing, Function}=nothing,
                 alg=:vf2)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}

    if alg == :vf2
        make_callback(c) = vmap -> (put!(c, collect(zip(vmap,1:length(vmap)))), return true)
        T = Vector{Tuple{eltype(g1), eltype(g2)}}
        ch::Channel{T} = Channel(ctype=T) do c
            vf2(make_callback(c), g1, g2, IsomorphismProblem, 
                           vertex_relation=vertex_relation,
                           edge_relation=edge_relation)
        end
        return ch
    else
        throw(ArgumentError("Keyword argument alg must be :vf2"))
    end
end

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
Iterates over all isomorphism between the graphs `g1` (or subgraphs thereof) and `g2`.
The problem that is solved depends on the value of `problemtype`:
- IsomorphismProblem: Only isomorphisms between the whole graph `g1` and `g2` are considered.
- SubGraphIsomorphismProblem: All isomorphism between subgraphs of `g1` and `g2` are considered.
- InducedSubGraphIsomorphismProblem: All isomorphism between vertex induced subgraphs of `g1` and `g2` are considered.

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
function vf2(callback::Function, g1::G, g2::G, problemtype::GraphMorphismProblemType; 
             vertex_relation::Union{Nothing, Function}=nothing, 
             edge_relation::Union{Nothing, Function}=nothing) where {G <: AbstractSimpleGraph}
    if has_self_loops(g1) || has_self_loops(g2)
        throw(ArgumentError("vf2 does not support self-loops at the moment"))
    end

    if nv(g1) < nv(g2) || (problemtype == IsomorphismProblem && nv(g1) != nv(g2))
        return 
    end

    start_state = VF2State(g1, g2)
    start_depth = 1
    vf2match!(start_state, start_depth, callback, problemtype, vertex_relation, edge_relation)
end

"""
    vf2check_feasibility(u, v, state, problemtype, vertex_relation, edge_relation)

Function that is used by vf2match! to check whether two vertices of G₁ and G₂ can be matched
"""
function vf2check_feasibility(u, v, state::VF2State, problemtype,
                              vertex_relation::Union{Nothing, Function},
                              edge_relation::Union{Nothing, Function})
    # TODO handle self-loops
    @inline function vf2rule_pred(u, v, state::VF2State, problemtype)
        if problemtype != SubGraphIsomorphismProblem
            @inbounds for u2 in inneighbors(state.g1, u)
                if state.core_1[u2] != 0
                    found = false
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
        if problemtype != SubGraphIsomorphismProblem
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
        if problemtype == IsomorphismProblem
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
        if problemtype == IsomorphismProblem
            return count1 == count2   
        end
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
        if problemtype == IsomorphismProblem
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
        if problemtype == IsomorphismProblem
            return count1 == count2   
        end
        return count1 >= count2   
    end

    @inline function vf2rule_new(u, v, state::VF2State, problemtype)
        problemtype == SubGraphIsomorphismProblem && return true
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
        if problemtype == IsomorphismProblem
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
        if problemtype == IsomorphismProblem
            return count1 == count2   
        end
        return count1 >= count2
    end

    syntactic_feasability = vf2rule_pred(u, v, state, problemtype) && 
                            vf2rule_succ(u, v, state, problemtype) && 
                            vf2rule_in(u, v, state, problemtype)   && 
                            vf2rule_out(u, v, state, problemtype)  && 
                            vf2rule_new(u, v, state, problemtype)
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
Helper function for vf2match! that updates the state before recursing.
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
Helper function for vf2match! that resets the state after returnin from recursing.
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
    vf2match!(state, detph, callback, problemtype, vertex_relation, edge_relation)
The recursing function that is called by vf2
"""
function vf2match!(state, depth, callback::Function, problemtype::GraphMorphismProblemType,
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
