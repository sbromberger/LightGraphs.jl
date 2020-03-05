"""
    struct BFS <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [Breadth-First Search algorithm](https://en.m.wikipedia.org/wiki/Breadth-first_search).

An optional sorting algorithm may be specified (default = no sorting).
Sorting helps maintain cache locality and will improve performance on
very large graphs; for normal use, sorting will incur a performance
penalty.

`BFS` is the default algorithm used when a source is specified
but no distance matrix is specified.

### Optional Fields
`maxdist::Int64` (default: `typemax(Int64)`) specifies the maximum path distance, in terms of number of edges, 
beyond which all path distances are assumed to be infinite (that is, they do not exist).

### Implementation Notes
`BFS` supports the following shortest-path functionality:
- (optional) multiple sources
- all destinations
"""
struct BFS{T} <: ShortestPathAlgorithm
    traversal::T
    maxdist::Int64
end

BFS(; sort_alg=Traversals.NOOPSort, neighborfn=outneighbors, maxdist=typemax(Int64)) = BFS(Traversals.BreadthFirst(sort_alg=sort_alg, neighborfn=neighborfn), maxdist)

mutable struct BFSSPState{U} <: Traversals.AbstractTraversalState
    parents::Vector{U}
    dists::Vector{U}
    n_level::U
    maxdist::U
end

@inline function initfn!(s::BFSSPState, u)
    s.dists[u] = 0
    return true
end
@inline function newvisitfn!(s::BFSSPState, u, v) 
    s.dists[v] = s.n_level
    s.parents[v] = u
    return true
end
@inline function postlevelfn!(s::BFSSPState{U}) where U
    s.n_level += one(U)
    return s.n_level <= s.maxdist
end

struct BFSResult{U<:Integer} <: ShortestPathResult
    parents::Vector{U}
    dists::Vector{U}
end

function shortest_paths(
    g::AbstractGraph{U},
    ss::AbstractVector{U},
    alg::BFS
   ) where U <: Integer

    n = nv(g)
    dists = fill(typemax(U), n)
    parents = zeros(U, n)
    md = alg.maxdist > typemax(U) ? typemax(U) : U(alg.maxdist)
    state = BFSSPState(parents, dists, one(U), md)
    Traversals.traverse_graph!(g, ss, alg.traversal, state)
    return BFSResult(state.parents, state.dists)
end

shortest_paths(g::AbstractGraph{U}, ss::AbstractVector{<:Integer}, alg::BFS) where {U<:Integer} = shortest_paths(g, U.(ss), alg)
shortest_paths(g::AbstractGraph{U}, s::Integer, alg::BFS) where {U<:Integer} = shortest_paths(g, Vector{U}([s]), alg)
