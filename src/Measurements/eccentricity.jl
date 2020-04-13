struct Eccentricities{T<:Real} <: GraphMeasurement
    vals::Vector{T}
    min::T
    max::T
end

function _eccentricities(g::AbstractGraph,
                         vs::AbstractVector{<:Integer},
                         distmx::AbstractMatrix{T},
                         alg::ShortestPathAlgorithm,
                         use_vs::Bool,
                         use_dists::Bool) where {T<:Real}

    v = use_vs ? vs : vertices(g)

    if alg isa APSPAlgorithm
        if use_dists
            sps = shortest_paths(g, distmx, alg)
    e = use_dists ? maximum(distances(shortest_paths(g, v, distmx, alg))) :
                    maximum(distances(shortest_paths(g, v, alg)))
    e == typemax(T) && @warn("Infinite path length detected for vertex $v")

    return Eccentricities(e, 
end
Eccentricities() = Eccentricities(Vector{Int}(), typemax(Int), 0)
Eccentricities(g::AbstractGraph) = _eccentricities(g, 

"""
    eccentricities(g[, vs[, distmx]][, alg])

Return an [`Eccentricities`](@ref) object representing the eccentricity[ies] of a vertex / 
vertex list `vs` defaulting to the entire graph. An optional matrix of edge distances may
be supplied. An optional [`ShortestPathAlgorithm`](@ref) may also be supplied (defaults to
[`ShortestPath.Dijkstra`](@ref) if distances are provided, [`ShortestPaths.BFS`](@ref)
otherwise.

The eccentricity of a vertex is the maximum shortest-path distance between it
and all other vertices in the graph.

The output is an [`Eccentricities`](@ref) object.

### Performance
Because this function must calculate shortest paths for all vertices supplied
in the argument list, it may take a long time.

### Implementation Notes
The [`Eccentricities`](@ref) structure returned by `eccentricities()` may be used as input
for other [graph measures](@ref GraphMeasurement) or [vertex subsets](@ref VertexSubset).
If an `Eccentricities` struct is provided, it will be used. Otherwise, the eccentricities
will be calculated for each call to the function. It may therefore be more efficient to
calculate, store, and pass the eccentricities if multiple distance measures are desired.

An infinite path length is represented by the `typemax` of the distance matrix.

"""
    eccentricity(g[, v][, distmx][, alg])
    eccentricity(g[, vs][, distmx][, alg])

Return the eccentricity[ies] of a vertex / vertex list `v` or a set of vertices
`vs` defaulting to the entire graph. An optional matrix of edge distances may
be supplied; if missing, edge distances default to `1`. An optional
[`ShortestPathAlgorithm`](@ref) may also be supplied (defaults to
[`ShortestPath.Dijkstra`](@ref) if distances are provided, [`ShortestPaths.BFS`](@ref)
otherwise..

The eccentricity of a vertex is the maximum shortest-path distance between it
and all other vertices in the graph.

The output is either a single float (when a single vertex is provided) or a
vector of floats corresponding to the vertex vector. If no vertex vector is
provided, the vector returned corresponds to each vertex in the graph.

### Performance
Because this function must calculate shortest paths for all vertices supplied
in the argument list, it may take a long time.

### Implementation Notes
The eccentricity vector returned by `eccentricity()` may be used as input
for the rest of the distance measures below. If an eccentricity vector is
provided, it will be used. Otherwise, an eccentricity vector will be calculated
for each call to the function. It may therefore be more efficient to calculate,
store, and pass the eccentricities if multiple distance measures are desired.

An infinite path length is represented by the `typemax` of the distance matrix.

# Examples
```jldoctest
julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> eccentricity(g, 1)
2

julia> eccentricity(g, [1; 2])
2-element Array{Int64,1}:
 2
 1

julia> eccentricity(g, [1; 2], [0 2 0; 0.5 0 0.5; 0 2 0])
2-element Array{Float64,1}:
 2.5
 0.5
```
"""
function eccentricity end

function _eccentricity(g::AbstractGraph,
    v::Integer,
    distmx::AbstractMatrix{T},
    alg::ShortestPathAlgorithm, use_dists::Bool) where {T<:Real}
    e = use_dists ? maximum(distances(shortest_paths(g, v, distmx, alg))) :
                    maximum(distances(shortest_paths(g, v, alg)))
    e == typemax(T) && @warn("Infinite path length detected for vertex $v")

    return e
end

eccentricity(g::AbstractGraph, v::Integer, alg::ShortestPathAlgorithm=BFS()) = 
    _eccentricity(g, v, zeros(0,0), alg, false)

eccentricity(g::AbstractGraph, v::Integer, distmx::AbstractMatrix, alg::ShortestPathAlgorithm=Dijkstra()) =
    _eccentricity(g, v, distmx, alg, true)

eccentricity(g::AbstractGraph, vs::AbstractVector{<:Integer}, alg::ShortestPathAlgorithm=BFS()) =
    [eccentricity(g, v, alg) for v in vs]
        
eccentricity(g::AbstractGraph, vs::AbstractVector{<:Integer}, distmx::AbstractMatrix, alg::ShortestPathAlgorithm=Dijkstra()) =
    [eccentricity(g, v, distmx, alg) for v in vs]
        
eccentricity(g::AbstractGraph, alg::ShortestPathAlgorithm=BFS()) = eccentricity(g, vertices(g), alg)

