# used in shortest path calculations

"""
    DefaultDistance

An array-like structure that provides distance values of `1` for any `src, dst` combination.
"""
struct DefaultDistance <: AbstractMatrix{Int}
    nv::Int
    DefaultDistance(nv::Int=typemax(Int)) = new(nv)
end

DefaultDistance(nv::Integer) = DefaultDistance(Int(nv))

show(io::IO, x::DefaultDistance) = print(io, "$(x.nv) × $(x.nv) default distance matrix (value = 1)")
show(io::IO, z::MIME"text/plain", x::DefaultDistance) = show(io, x)

getindex(::DefaultDistance, s::Integer, d::Integer) = 1
getindex(::DefaultDistance, s::UnitRange, d::UnitRange) = DefaultDistance(length(s))
size(d::DefaultDistance) = (d.nv, d.nv)
transpose(d::DefaultDistance) = d
ctranspose(d::DefaultDistance) = d

"""
    eccentricity(g[, v][, distmx])
    eccentricity(g[, vs][, distmx])
    parallel_eccentricity(g[, vs][, distmx])

Return the eccentricity[ies] of a vertex / vertex list `v` or a set of vertices 
`vs` defaulting to the entire graph. An optional matrix of edge distances may
be supplied; if missing, edge distances default to `1`.

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
"""
function eccentricity(g::AbstractGraph,
    v::Integer,
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real
    e = maximum(dijkstra_shortest_paths(g, v, distmx).dists)
    e == typemax(T) && warn("Infinite path length detected for vertex $v")

    return e
end

eccentricity(g::AbstractGraph,
    vs::AbstractVector=vertices(g),
    distmx::AbstractMatrix=weights(g)) = [eccentricity(g, v, distmx) for v in vs]


eccentricity(g::AbstractGraph, distmx::AbstractMatrix) =
    eccentricity(g, vertices(g), distmx)

function parallel_eccentricity(g::AbstractGraph,
    vs::AbstractVector=vertices(g),
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real
    vlen = length(vs)
    eccs = SharedVector{T}(vlen)
    @sync @distributed for i = 1:vlen
        eccs[i] = maximum(dijkstra_shortest_paths(g, vs[i], distmx).dists)
    end
    d = sdata(eccs)
    maximum(d) == typemax(T) && warn("Infinite path length detected")
    return d
end

parallel_eccentricity(g::AbstractGraph, distmx::AbstractMatrix) =
    parallel_eccentricity(g, vertices(g), distmx)

"""
    diameter(eccentricities)
    diameter(g, distmx=weights(g))
    parallel_diameter(g, distmx=weights(g))
    
Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the maximum eccentricity of the graph.
"""
diameter(eccentricities::Vector) = maximum(eccentricities)
diameter(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    maximum(eccentricity(g, distmx))
parallel_diameter(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    maximum(parallel_eccentricity(g, distmx))

"""
    periphery(eccentricities)
    periphery(g, distmx=weights(g))
    parallel_periphery(g, distmx=weights(g))
    
Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the set of all vertices whose eccentricity is
equal to the graph's diameter (that is, the set of vertices with the
largest eccentricity).
"""
function periphery(eccentricities::Vector)
    diam = maximum(eccentricities)
    return filter(x -> eccentricities[x] == diam, 1:length(eccentricities))
end

periphery(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) = 
    periphery(eccentricity(g, distmx))

parallel_periphery(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    periphery(parallel_eccentricity(g, distmx))

"""
    radius(eccentricities)
    radius(g, distmx=weights(g))
    parallel_radius(g, distmx=weights(g))
    

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the minimum eccentricity of the graph.
"""
radius(eccentricities::Vector) = minimum(eccentricities)
radius(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    minimum(eccentricity(g, distmx))
parallel_radius(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    minimum(parallel_eccentricity(g, distmx))

"""
    center(eccentricities)
    center(g, distmx=weights(g))
    parallel_center(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the set of all vertices whose eccentricity is equal
to the graph's radius (that is, the set of vertices with the smallest eccentricity).
"""
function center(eccentricities::Vector)
    rad = radius(eccentricities)
    return filter(x -> eccentricities[x] == rad, 1:length(eccentricities))
end

center(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    center(eccentricity(g, distmx))

parallel_center(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    center(parallel_eccentricity(g, distmx))
