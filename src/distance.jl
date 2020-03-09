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
adjoint(d::DefaultDistance) = d

"""
    eccentricity(g[, v][, distmx])
    eccentricity(g[, vs][, distmx])

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
function eccentricity(g::AbstractGraph,
    v::Integer,
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real
    e = maximum(dijkstra_shortest_paths(g, v, distmx).dists)
    e == typemax(T) && @warn("Infinite path length detected for vertex $v")

    return e
end

eccentricity(g::AbstractGraph,
    vs::AbstractVector=vertices(g),
    distmx::AbstractMatrix=weights(g)) = [eccentricity(g, v, distmx) for v in vs]


eccentricity(g::AbstractGraph, distmx::AbstractMatrix) =
    eccentricity(g, vertices(g), distmx)

"""
    diameter(eccentricities)
    diameter(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the maximum eccentricity of the graph.

# Examples
```jldoctest
julia> using LightGraphs

julia> diameter(star_graph(5))
2

julia> diameter(path_graph(5))
4
```
"""
diameter(eccentricities::Vector) = maximum(eccentricities)
diameter(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    maximum(eccentricity(g, distmx))

"""
    periphery(eccentricities)
    periphery(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the set of all vertices whose eccentricity is
equal to the graph's diameter (that is, the set of vertices with the
largest eccentricity).

# Examples
```jldoctest
julia> using LightGraphs

julia> periphery(star_graph(5))
4-element Array{Int64,1}:
 2
 3
 4
 5

julia> periphery(path_graph(5))
2-element Array{Int64,1}:
 1
 5
```
"""
function periphery(eccentricities::Vector)
    diam = maximum(eccentricities)
    return filter(x -> eccentricities[x] == diam, 1:length(eccentricities))
end

periphery(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    periphery(eccentricity(g, distmx))

"""
    radius(eccentricities)
    radius(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the minimum eccentricity of the graph.

# Examples
```jldoctest
julia> using LightGraphs

julia> radius(star_graph(5))
1

julia> radius(path_graph(5))
2
```
"""
radius(eccentricities::Vector) = minimum(eccentricities)
radius(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    minimum(eccentricity(g, distmx))

"""
    center(eccentricities)
    center(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the set of all vertices whose eccentricity is equal
to the graph's radius (that is, the set of vertices with the smallest eccentricity).

# Examples
```jldoctest
julia> using LightGraphs

julia> center(star_graph(5))
1-element Array{Int64,1}:
 1

julia> center(path_graph(5))
1-element Array{Int64,1}:
 3
```
"""
function center(eccentricities::Vector)
    rad = radius(eccentricities)
    return filter(x -> eccentricities[x] == rad, 1:length(eccentricities))
end

center(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    center(eccentricity(g, distmx))
