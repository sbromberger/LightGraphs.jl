import Base.showerror
struct CycleError <: Exception end
Base.showerror(io::IO, e::CycleError) = print(io, "Cycles are not allowed in this function.")



struct DepthFirst{F<:Function} <: TraversalAlgorithm
    neighborfn::F
end

DepthFirst(;neighborfn=outneighbors) = DepthFirst(neighborfn)

function traverse_graph!(
    g::AbstractGraph{U},
    ss::AbstractVector,
    alg::DepthFirst,
    state::AbstractTraversalState,
    ) where U<:Integer

    n = nv(g)
    visited = falses(n)
    S = Vector{Tuple{U,U}}()
    sizehint!(S, length(ss))
    preinitfn!(state, visited) || return false
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(S, (us, 1))
        initfn!(state, us) || return false
    end

    ptr = one(U)

    while !isempty(S)
        v, _ = S[end]
        previsitfn!(state, v) || return false

        neighs=alg.neighborfn(g, v)
        @inbounds while ptr <= length(neighs)
            i = neighs[ptr]
            visitfn!(state, v, i) || return false
            if !visited[i]  # find the first unvisited neighbor
                newvisitfn!(state, v, i) || return false
                visited[i] = true
                push!(S, (i, ptr+1))
                break
            end
            ptr += 1
        end
        postvisitfn!(state, v) || return false
        # if ptr > length(neighs) then we have finished all children of the node,
        # and the next time we pop from the stack we will be in the parent of the current
        # node. We would like to continue from where we stoped, otherwise we have found
        # a new unvisited child, so we will make ptr = 1
        if ptr > length(neighs)
            postlevelfn!(state) || return false
            _, ptr =pop!(S)
        else
            ptr = 1 # we will enter new node
        end
    end
    return true
end

mutable struct TopoSortState{T<:Integer} <: AbstractTraversalState
    vcolor::Vector{UInt8}
    verts::Vector{T}
    w::T
end

# 1 = visited
# 2 = vcolor 2
# @inline initfn!(s::TopoSortState{T}, u) where T = s.vcolor[u] = one(T)
@inline function previsitfn!(s::TopoSortState{T}, u) where T
    s.w = 0
    return true
end
@inline function visitfn!(s::TopoSortState{T}, u, v) where T
    return s.vcolor[v] != one(T)
end
@inline function newvisitfn!(s::TopoSortState{T}, u, v) where T
    s.w = v
    return true
end
@inline function postvisitfn!(s::TopoSortState{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
        push!(s.verts, u)
    end
    return true
end


@traitfn function topological_sort(g::AG::IsDirected, alg::DepthFirst=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    state = TopoSortState(vcolor, verts, zero(T))
    
    sources = filter(x -> indegree(g, x) == 0, vertices(g))
 
    traverse_graph!(g, sources, DepthFirst(), state) || throw(CycleError())
      
    length(state.verts) < nv(g) && throw(CycleError())
    length(state.verts) > nv(g) && throw(TraversalError())
    
    
    return reverse!(state.verts)
end

mutable struct CycleState{T<:Integer} <: AbstractTraversalState
    vcolor::Vector{UInt8}
    w::T
end

@inline function previsitfn!(s::CycleState{T}, u) where T
    s.w = 0
    return true
end
@inline function visitfn!(s::CycleState{T}, u, v) where T
    return s.vcolor[v] != one(T)
end
@inline function newvisitfn!(s::CycleState{T}, u, v) where T
    s.w = v
    return true
end
@inline function postvisitfn!(s::CycleState{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
    end
    return true
end

@traitfn function is_cyclic(g::AG::IsDirected, alg::DepthFirst=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    state = CycleState(vcolor, zero(T))
    @inbounds for v in vertices(g)
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        !traverse_graph!(g, v, DepthFirst(), state) && return true
    end
    return false
end

@traitfn is_cyclic(g::::(!IsDirected), alg::DepthFirst=DepthFirst()) = ne(g) > 0



mutable struct BiconnectionState{E <: AbstractEdge} <: AbstractTraversalState

    low::Vector{Int}
    depth::Vector{Int}
    stack::Vector{E}
    components::Vector{Vector{E}}
    id::Int
    up::Bool
    lastnode::Int
    lastlow::Int
    have_children::Vector{Bool}
    parent::Vector{Int}
end




@inline function previsitfn!(s::BiconnectionState{E}, u) where E
    if s.up == false
        push!(s.have_children, false)
        s.id+=1
        s.depth[u] = s.id
        push!(s.low,s.id)
    elseif s.depth[u] <= s.lastlow
        w = s.lastnode
        e = E(0, 0)  #Invalid Edge, used for comparison only
        st = Vector{E}()
        while e != E(min(u, w), max(u, w)) && !isempty(s.stack)
            e = pop!(s.stack)
            push!(st, e)
        end
        push!(s.components , st)
    elseif s.low[end] > s.lastlow
        s.low[end] = s.lastlow
    end
    return true
end

@inline function visitfn!(s::BiconnectionState{E}, u, v) where E

    (v == s.parent[end] || s.depth[u] < s.depth[v]) && return true

    push!(s.stack, E(min(v, u), max(v, u)))
    if s.depth[v] != 0
        s.low[end] = min(s.low[end], s.depth[v])
    else
        push!(s.parent,u)
        s.have_children[end]|= true
        s.up = false
    end
    return true
end

@inline function postvisitfn!(s::BiconnectionState{E}, u) where E
    if s.have_children[end] == false
        s.up = true
    end

    if s.up
        s.lastnode = u
        s.lastlow = pop!(s.low)
        pop!(s.have_children)
        pop!(s.parent)
    end

    return true
end

function BiconnectionState(g)
    n = nv(g)
    E = Edge{eltype(g)}
    return BiconnectionState(Vector{Int}(), zeros(Int, n), Vector{E}(), Vector{Vector{E}}(), 0, false, -1, -1, Vector{Bool}(), Vector{Int}())
end


"""
    biconnected_components(g) -> Vector{Vector{Edge{eltype(g)}}}

Compute the [biconnected components](https://en.wikipedia.org/wiki/Biconnected_component)
of an undirected graph `g`and return a vector of vectors containing each
biconnected component.

Performance:
Time complexity is ``\\mathcal{O}(|V|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> biconnected_components(star_graph(5))
4-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 3]
 [Edge 1 => 4]
 [Edge 1 => 5]
 [Edge 1 => 2]

julia> biconnected_components(cycle_graph(5))
1-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 5, Edge 4 => 5, Edge 3 => 4, Edge 2 => 3, Edge 1 => 2]
```
"""





 function biconnected_components(g::SimpleGraph)
    state = BiconnectionState(g)
    for u in vertices(g)
        if state.depth[u] == 0
            push!(state.parent,-1)
            state.up = false
            traverse_graph!(g, u, DepthFirst(), state)
        end
    end
    return state.components
end
