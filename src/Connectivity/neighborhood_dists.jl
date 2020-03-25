mutable struct NeighborState{T, U} <: LightGraphs.Traversals.TraversalState
    maxdist::U
    vdists::Vector{Tuple{T, T}}
    nlevel::T
end

@inline function initfn!(state::NeighborState{T, U}, u) where {T, U}
    state.maxdist < zero(U) && return false
    push!(state.vdists, (u, zero(T)))
    return state.maxdist > zero(U)
end

@inline function newvisitfn!(state::NeighborState, u, v)
    push!(state.vdists, (v, state.nlevel))
    return true
end

@inline function postlevelfn!(state::NeighborState{T, U}) where {T, U}
    state.nlevel += one(T)
    return state.nlevel <= state.maxdist
end


"""
    neighborhood_dists(g, v, d; neighborfn=outneighbors)
    neighborhood_dists(g, v, d, distmx; neighborfn=outneighbors)

Return a a vector of tuples representing each vertex which is at a geodesic distance less than or equal to `d`, along with
its distance from `v`. Non-negative distances may be specified by `distmx`.

### Optional Arguments
- `neighborfn=outneighbors`: If `g` is directed, this argument specifies the neighbor function used
to derive the edges with respect to `v`. 

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> neighborhood_dists(g, 1, 3)
4-element Array{Tuple{Int64,Int64},1}:
 (1, 0)
 (2, 1)
 (3, 2)
 (4, 3)

julia> neighborhood_dists(g, 1, 3, [0 1 0 0 0; 0 0 1 0 0; 1 0 0 0.25 0; 0 0 0 0 0.25; 0 0 0 0.25 0])
5-element Array{Tuple{Int64,Float64},1}:
 (1, 0.0)
 (2, 1.0)
 (3, 2.0)
 (4, 2.25)
 (5, 2.5)

julia> neighborhood_dists(g, 4, 3)
2-element Array{Tuple{Int64,Int64},1}:
 (4, 0)
 (5, 1)

julia> neighborhood_dists(g, 4, 3, neighborfn=inneighbors)
5-element Array{Tuple{Int64,Int64},1}:
 (4, 0)
 (3, 1)
 (5, 1)
 (2, 2)
 (1, 3)
```
"""
function neighborhood_dists(g::AbstractGraph{T}, ss, maxdist; neighborfn=outneighbors) where {T}
    v = Vector{Tuple{T, T}}()
    s = NeighborState(maxdist, v, one(T))
    LightGraphs.Traversals.traverse_graph!(g, ss, LightGraphs.Traversals.BreadthFirst(neighborfn=neighborfn), s)
    return s.vdists
end

function neighborhood_dists(g::AbstractGraph{T}, ss, maxdist, distmx::AbstractMatrix; neighborfn=outneighbors) where {T}
    ds = LightGraphs.ShortestPaths.Dijkstra(neighborfn=neighborfn, maxdist=maxdist)
    d = LightGraphs.ShortestPaths.shortest_paths(g, ss, distmx, ds)
    return collect(Iterators.filter(x-> x[2] <= maxdist, zip(vertices(g), LightGraphs.ShortestPaths.distances(d))))
end

"""
    neighborhood(g, v, d, distmx=weights(g); neighborfn=outneighbors)

Return a vector of each vertex in `g` at a geodesic distance less than or equal to `d`, where distances
may be specified by `distmx`.

### Optional Arguments
- `neighborfn=outneighbors`: If `g` is directed, this argument specifies the neighbor function used
to derive the edges with respect to `v`. 

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> neighborhood(g, 1, 2)
3-element Array{Int64,1}:
 1
 2
 3

julia> neighborhood(g, 1, 3)
4-element Array{Int64,1}:
 1
 2
 3
 4

julia> neighborhood(g, 1, 3, [0 1 0 0 0; 0 0 1 0 0; 1 0 0 0.25 0; 0 0 0 0 0.25; 0 0 0 0.25 0])
5-element Array{Int64,1}:
 1
 2
 3
 4
 5
```
"""
neighborhood(g, ss, maxdist; neighborfn=outneighbors) = first.(neighborhood_dists(g, ss, maxdist; neighborfn=neighborfn))
neighborhood(g, ss, maxdist, distmx; neighborfn=outneighbors) = first.(neighborhood_dists(g, ss, maxdist, distmx; neighborfn=neighborfn))

