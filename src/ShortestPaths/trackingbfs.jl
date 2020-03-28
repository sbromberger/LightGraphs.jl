"""
    struct TrackingBFS <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [Breadth-First Search algorithm](https://en.m.wikipedia.org/wiki/Breadth-first_search).

This version of BFS will keep track of pathcounts and all predecessors.

An optional sorting algorithm may be specified (default = no sorting).
Sorting helps maintain cache locality and will improve performance on
very large graphs; for normal use, sorting will incur a performance
penalty.

### Optional Fields
`maxdist::Int64` (default: `typemax(Int64)`) specifies the maximum path distance, in terms of number of edges, 
beyond which all path distances are assumed to be infinite (that is, they do not exist).

### Implementation Notes
`TrackingBFS` supports the following shortest-path functionality:
- (optional) multiple sources
- all destinations
- redundant equivalent path tracking
- vertex tracking
"""
struct TrackingBFS{T} <: ShortestPathAlgorithm
    traversal::T
    maxdist::Int64
end

TrackingBFS(; traversal=Traversals.BreadthFirst(), maxdist=typemax(Int64)) = TrackingBFS(traversal, maxdist)
TrackingBFS(a::Base.Sort.Algorithm; maxdist=typemax(Int64)) = TrackingBFS(Traversals.BreadthFirst(a), maxdist)

mutable struct TrackingBFSSPState{U} <: Traversals.TraversalState
    parents::Vector{U}
    dists::Vector{U}
    n_level::U
    pathcounts::Vector{U}
    preds::Vector{Vector{U}}
    closest_vertices::Vector{U}
    maxdist::U
end

@inline function initfn!(s::TrackingBFSSPState, u)
    s.dists[u] = 0
    s.pathcounts[u] = 1
    push!(s.closest_vertices, u)
    return true
end

@inline function newvisitfn!(s::TrackingBFSSPState, u, v) 
    s.dists[v] = s.n_level
    s.parents[v] = u
    push!(s.closest_vertices, v)
    s.pathcounts[v] = s.pathcounts[u]
    s.preds[v] = [u;]
    return true
end

function revisitfn!(s::TrackingBFSSPState, u, v)
    if s.dists[v] == s.n_level   # this is another shortest path.
        s.pathcounts[v] += s.pathcounts[u] 
        push!(s.preds[v], u)
    end
    return true
end

@inline function postlevelfn!(s::TrackingBFSSPState{U}) where {U}
    s.n_level += one(U)
    return true
end



struct TrackingBFSResult{U<:Integer} <: ShortestPathResult
    parents::Vector{U}
    dists::Vector{U}
    pathcounts::Vector{U}
    preds::Vector{Vector{U}}
    closest_vertices::Vector{U}
end

function shortest_paths(
    g::AbstractGraph{U},
    ss::AbstractVector{U},
    alg::TrackingBFS
   ) where U <: Integer

    n = nv(g)
    dists = fill(typemax(U), n)
    parents = zeros(U, n)
    preds = fill(Vector{U}(), n)
    pathcounts = zeros(U, n)
    closest_vertices = Vector{U}()
    sizehint!(closest_vertices, n)

    md = alg.maxdist > typemax(U) ? typemax(U) : U(alg.maxdist)
    # parents::Vector{U}
    # dists::Vector{U}
    # n_level::U
    # pathcounts::Vector{U}
    # preds::Vector{Vector{U}}
    # closest_vertices::Vector{U}
    # maxdist::U
    state = TrackingBFSSPState(parents, dists, one(U), pathcounts, preds, closest_vertices, md)
    Traversals.traverse_graph!(g, ss, alg.traversal, state)
    return TrackingBFSResult(state.parents, state.dists, state.pathcounts, state.preds, state.closest_vertices)
end




shortest_paths(g::AbstractGraph{U}, ss::AbstractVector{<:Integer}, alg::TrackingBFS) where {U<:Integer} = shortest_paths(g, U.(ss), alg)
shortest_paths(g::AbstractGraph{U}, s::Integer, alg::TrackingBFS) where {U<:Integer} = shortest_paths(g, Vector{U}([s]), alg)
