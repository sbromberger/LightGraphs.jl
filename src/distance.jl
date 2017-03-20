# used in shortest path calculations

struct DefaultDistance<:AbstractMatrix{Int}
    nv::Int
    DefaultDistance(nv::Int=typemax(Int)) = new(nv)
end

getindex(::DefaultDistance, s::Integer, d::Integer) = 1
getindex(::DefaultDistance, s::UnitRange, d::UnitRange) = DefaultDistance(length(s))
size(d::DefaultDistance) = (d.nv, d.nv)
transpose(d::DefaultDistance) = d
ctranspose(d::DefaultDistance) = d

"""
Calculates the eccentricity[ies] of a vertex `v`, vertex vector `vs`, or the
entire graph. An optional matrix of edge distances may be supplied.

The eccentricity of a vertex is the maximum shortest-path distance between it
and all other vertices in the graph.

Because this function must calculate shortest paths for all vertices supplied
in the argument list, it may take a long time.

The output is either a single float (when a single vertex is provided) or a
vector of floats corresponding to the vertex vector. If no vertex vector is
provided, the vector returned corresponds to each vertex in the graph.

Note: the eccentricity vector returned by `eccentricity()` may be used as input
for the rest of the distance measures below. If an eccentricity vector is
provided, it will be used. Otherwise, an eccentricity vector will be calculated
for each call to the function. It may therefore be more efficient to calculate,
store, and pass the eccentricities if multiple distance measures are desired.
"""
function eccentricity(
    g::AbstractGraph,
    v::Integer,
    distmx::AbstractMatrix{T} = DefaultDistance()
) where T
    e = maximum(dijkstra_shortest_paths(g,v,distmx).dists)
    e == typemax(T) && error("Infinite path length detected")

    return e
end

eccentricity(
    g::AbstractGraph,
    vs::AbstractVector = vertices(g),
    distmx::AbstractMatrix = DefaultDistance()
) = [eccentricity(g,v,distmx) for v in vs]

eccentricity(g::AbstractGraph, distmx::AbstractMatrix) =
    eccentricity(g, vertices(g), distmx)

"""Returns the maximum eccentricity of the graph."""
diameter(all_e::Vector{T}) where T = maximum(all_e)
diameter(g::AbstractGraph, distmx::AbstractMatrix{T} = DefaultDistance()) where T =
    maximum(eccentricity(g, distmx))

"""Returns the set of all vertices whose eccentricity is equal to the graph's
diameter (that is, the set of vertices with the largest eccentricity).
"""
function periphery(all_e::Vector{T}) where T
    diam = maximum(all_e)
    return filter((x)->all_e[x] == diam, 1:length(all_e))
end

periphery(g::AbstractGraph, distmx::AbstractMatrix = DefaultDistance()) =
    periphery(eccentricity(g, distmx))

"""Returns the minimum eccentricity of the graph."""
radius{T}(all_e::Vector{T}) = minimum(all_e)
radius{T}(g::AbstractGraph, distmx::AbstractMatrix{T} = DefaultDistance()) =
    minimum(eccentricity(g, distmx))

"""Returns the set of all vertices whose eccentricity is equal to the graph's
radius (that is, the set of vertices with the smallest eccentricity).
"""
function center{T}(all_e::Vector{T})
    rad = radius(all_e)
    return filter((x)->all_e[x] == rad, 1:length(all_e))
end

center{T}(g::AbstractGraph, distmx::AbstractMatrix{T} = DefaultDistance()) =
    center(eccentricity(g, distmx))
