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
    eccentricity(g[, v][, distmx])

Return the eccentricity[ies] of a vertex / vertex list `v` or the
entire graph. An optional matrix of edge distances may be supplied; if missing,
edge distances default to `1`.

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

"""
    diameter(g, distmx=DefaultDistance())
    diameter(eccentricities)

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the maximum eccentricity of the graph.
"""
diameter(eccentricities::Vector) = maximum(eccentricities)
diameter(g::AbstractGraph, distmx::AbstractMatrix = DefaultDistance())=
    maximum(eccentricity(g, distmx))

"""
    periphery(g, distmx=DefaultDistance())
    periphery(eccentricities)

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the set of all vertices whose eccentricity is
equal to the graph's diameter (that is, the set of vertices with the
largest eccentricity).
"""
function periphery(eccentricities::Vector)
    diam = maximum(eccentricities)
    return filter((x)->eccentricities[x] == diam, 1:length(eccentricities))
end

periphery(g::AbstractGraph, distmx::AbstractMatrix = DefaultDistance()) =
    periphery(eccentricity(g, distmx))

"""
    radius(g, distmx=DefaultDistance())
    radius(eccentricities)

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the minimum eccentricity of the graph.
"""
radius(eccentricities::Vector) = minimum(eccentricities)
radius(g::AbstractGraph, distmx::AbstractMatrix = DefaultDistance()) =
    minimum(eccentricity(g, distmx))

"""
    center(g, distmx=DefaultDistance())
    center(eccentricities)

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the set of all vertices whose eccentricity is equal
to the graph's radius (that is, the set of vertices with the smallest eccentricity).
"""
function center(eccentricities::Vector)
    rad = radius(eccentricities)
    return filter((x)->eccentricities[x] == rad, 1:length(eccentricities))
end

center(g::AbstractGraph, distmx::AbstractMatrix = DefaultDistance()) =
    center(eccentricity(g, distmx))
