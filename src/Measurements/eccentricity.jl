"""
    struct Threaded <: AbstractGraphAlgorithm

A struct representing a threaded version of a measurement algorithm.
"""
struct Threaded end

"""
    struct Eccentricities <: GraphMeasurement

A structure representing the eccentricities calculated from a given graph.
"""
struct Eccentricities{T<:Real} <: GraphMeasurement
    vals::Vector{T}
    min::T
    max::T
end
Eccentricities(a::AbstractVector{<:Real}) = Eccentricities(a, extrema(a)...)

function _eccentricities(g::AbstractGraph,
                         vs::AbstractVector{<:Integer},
                         distmx::AbstractMatrix{T},
                         alg::SSSPAlgorithm,
                         use_vs::Bool,
                         use_dists::Bool,
                         ET) where {T<:Real}

    verts = use_vs ? vs : vertices(g)

    # BFS and Dijkstra across vertices are faster than APSP for sparse graphs.

    eccs = Vector{ET}()
    sizehint!(eccs, length(verts))
    mn = typemax(ET)
    mx = typemin(ET)
    if use_dists
        for v in verts
            sp = maximum(distances(shortest_paths(g, v, distmx, alg)))
            push!(eccs, sp)
            if sp < mn
                mn = sp
            end
            if sp > mx
                mx = sp
            end
            sp == typemax(ET) && @warn("Infinite path length detected for vertex $v: graph may not be connected")
        end
    else
        @inbounds for v in verts
            sp = maximum(distances(shortest_paths(g, v, alg)))
            push!(eccs, sp)
            if sp < mn
                mn = sp
            end
            if sp > mx
                mx = sp
            end
            sp == typemax(ET) && @warn("Infinite path length detected for vertex $v: graph may not be connected")
        end
    end
    
    return Eccentricities{ET}(eccs, mn, mx)
end

function _threaded_eccentricities(g::AbstractGraph,
                         vs::AbstractVector{<:Integer},
                         distmx::AbstractMatrix{T},
                         alg::SSSPAlgorithm,
                         use_vs::Bool,
                         use_dists::Bool,
                         ET) where {T<:Real}

    verts = use_vs ? vs : vertices(g)

    eccs = Vector{ET}(undef, length(verts))
    if use_dists
        @threads for i in 1:length(verts)
            v = verts[i]
            sp = maximum(distances(shortest_paths(g, v, distmx, alg)))
            eccs[i] = sp
            sp == typemax(ET) && @warn("Infinite path length detected for vertex $v: graph may not be connected")
        end
    else
        @threads for i in 1:length(verts)
            v = verts[i]
            sp = maximum(distances(shortest_paths(g, v, alg)))
            eccs[i] = sp
            sp == typemax(ET) && @warn("Infinite path length detected for vertex $v: graph may not be connected")
        end
    end
    mn, mx = extrema(eccs) 
    return Eccentricities{ET}(eccs, mn, mx)
end

"""
    eccentricities(g[, vs[, distmx]][, alg][, ::Threaded])

Return an [`Eccentricities`](@ref) object representing the eccentricity[ies] of a vertex / 
vertex list `vs` defaulting to the entire graph. An optional matrix of edge distances may
be supplied. An optional [`ShortestPathAlgorithm`](@ref) may also be supplied (defaults to
[`ShortestPath.Dijkstra`](@ref) if distances are provided, [`ShortestPaths.BFS`](@ref)
otherwise. A threaded calculation may be achieved using an instance of [`Threaded`](@ref)
as an argument.


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
eccentricities(g::AbstractGraph) = _eccentricities(g, [0], zeros(0,0), BFS(), false, false, eltype(g))
eccentricities(g::AbstractGraph, ::Threaded) = _threaded_eccentricities(g, [0], zeros(0,0), BFS(), false, false, eltype(g))

eccentricities(g::AbstractGraph, alg::SSSPAlgorithm) = _eccentricities(g, [0], zeros(0,0), alg, false, false, eltype(g))
eccentricities(g::AbstractGraph, alg::SSSPAlgorithm, ::Threaded) = _threaded_eccentricities(g, [0], zeros(0,0), alg, false, false, eltype(g))

eccentricities(g::AbstractGraph, vs::AbstractVector) = _eccentricities(g, vs, zeros(0,0), BFS(), true, false, eltype(g))
eccentricities(g::AbstractGraph, vs::AbstractVector, ::Threaded) = _threaded_eccentricities(g, vs, zeros(0,0), BFS(), true, false, eltype(g))

eccentricities(g::AbstractGraph, vs::AbstractVector, alg::SSSPAlgorithm) = _eccentricities(g, vs, zeros(0,0), alg, true, false, eltype(g))
eccentricities(g::AbstractGraph, vs::AbstractVector, alg::SSSPAlgorithm, ::Threaded) = _threaded_eccentricities(g, vs, zeros(0,0), alg, true, false, eltype(g))

eccentricities(g::AbstractGraph, v::Integer) = _eccentricities(g, [v], zeros(0,0), BFS(), true, false, eltype(g))

eccentricities(g::AbstractGraph, v::Integer, alg::SSSPAlgorithm) = _eccentricities(g, [v], zeros(0,0), alg, true, false, eltype(g))

eccentricities(g::AbstractGraph, distmx::AbstractMatrix) = _eccentricities(g, [0], distmx, Dijkstra(), false, true, eltype(distmx))
eccentricities(g::AbstractGraph, distmx::AbstractMatrix, ::Threaded) = _threaded_eccentricities(g, [0], distmx, Dijkstra(), false, true, eltype(distmx))

eccentricities(g::AbstractGraph, distmx::AbstractMatrix, alg::SSSPAlgorithm) = _eccentricities(g, [0], distmx, alg, false, true, eltype(distmx))
eccentricities(g::AbstractGraph, distmx::AbstractMatrix, alg::SSSPAlgorithm, ::Threaded) = _threaded_eccentricities(g, [0], distmx, alg, false, true, eltype(distmx))

eccentricities(g::AbstractGraph, vs::AbstractVector, distmx::AbstractMatrix) = _eccentricities(g, vs, distmx, Dijkstra(), true, true, eltype(distmx))
eccentricities(g::AbstractGraph, vs::AbstractVector, distmx::AbstractMatrix, ::Threaded) = _threaded_eccentricities(g, vs, distmx, Dijkstra(), true, true, eltype(distmx))

eccentricities(g::AbstractGraph, vs::AbstractVector, distmx::AbstractMatrix, alg::SSSPAlgorithm) = _eccentricities(g, vs, distmx, alg, true, true, eltype(distmx))
eccentricities(g::AbstractGraph, vs::AbstractVector, distmx::AbstractMatrix, alg::SSSPAlgorithm, ::Threaded) = _threaded_eccentricities(g, vs, distmx, alg, true, true, eltype(distmx))

eccentricities(g::AbstractGraph, v::Integer, distmx::AbstractMatrix) = _eccentricities(g, [v], distmx, Dijkstra(), true, true, eltype(distmx))

eccentricities(g::AbstractGraph, v::Integer, distmx::AbstractMatrix, alg::SSSPAlgorithm) = _eccentricities(g, [v], distmx, alg, true, true, eltype(distmx))

eccentricities(a::AbstractVector) = Eccentricities(a, extrema(a)...)

"""
    eccentricity(g[, vs[, distmx]][, alg][, ::Threaded])
    eccentricity(::Eccentricities)

Return the eccentricity[ies] of a vertex / vertex list `vs` defaulting to the
entire graph. An optional matrix of edge distances may also be supplied.
An optional [`ShortestPaths.SSSPAlgorithm`](@ref) may also be supplied (defaults to
[`ShortestPath.Dijkstra`](@ref) if distances are provided, [`ShortestPaths.BFS`](@ref)
otherwise. A threaded calculation may be achieved using an instance of [`Threaded`](@ref)
as an argument.


If an [`Eccentricities`](@ref) object is given instead, return the previously-calculated
eccentricities from that object.

The eccentricity of a vertex is the maximum shortest-path distance between it
and all other vertices in the graph.

### Performance
If an `Eccentricities` object is not provided, this function must calculate shortest paths for all vertices supplied
in the argument list and therefore may take a long time.


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
eccentricity(g::AbstractGraph, x...) = eccentricities(g, x...).vals
eccentricity(g::AbstractGraph, v::Integer, x...) = first(eccentricities(g, v, x...).vals)

"""
    diameter(::Eccentricities)
    diameter(g[, vs[, distmx]][, alg][, ::Threaded])

Given a precomputed [`Eccentricities`](@ref) struct, return the maximum
eccentricity of the graph.

In lieu of an `Eccentricities` struct, one may be (temporarily) created
for use by this function by passing in the corresponding parameters to
[`eccentricities`](@ref) instead. A threaded calculation may be achieved
using an instance of [`Threaded`](@ref) as an argument.


# Examples
```jldoctest
julia> using LightGraphs
julia> diameter(star_graph(5))
2
julia> diameter(path_graph(5))
4
```
"""
diameter(e::Eccentricities) = e.max
diameter(x...) = diameter(eccentricities(x...))

"""
    radius(::Eccentricities)
    radius(g[, vs[, distmx]][, alg][, ::Threaded])

Given a precomputed [`Eccentricities`](@ref) struct, return the minimum
eccentricity of the graph.

In lieu of an `Eccentricities` struct, one may be (temporarily) created
for use by this function by passing in the corresponding parameters to
[`eccentricities`](@ref) instead. A threaded calculation may be achieved
using an instance of [`Threaded`](@ref) as an argument.


# Examples
```jldoctest
julia> using LightGraphs
julia> radius(star_graph(5))
1
julia> radius(path_graph(5))
2
```
"""
radius(e::Eccentricities) = e.min
radius(x...) = radius(eccentricities(x...))

"""
    periphery(::Eccentricities)
    periphery(g[, vs[, distmx]][, alg][, ::Threaded])

Given a precomputed [`Eccentricities`](@ref) struct, return the set of
all vertices whose eccentricity is equal to the graph's diameter (that
is, the set of vertices with the largest eccentricity).

In lieu of an `Eccentricities` struct, one may be (temporarily) created
for use by this function by passing in the corresponding parameters to
[`eccentricities`](@ref) instead. A threaded calculation may be achieved
using an instance of [`Threaded`](@ref) as an argument.



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
periphery(e::Eccentricities) = findall(e.vals .== e.max)
periphery(x...) = periphery(eccentricities(x...))

"""
    center(::Eccentricities)
    center(g[, vs[, distmx]][, alg][, ::Threaded])

Given a precomputed [`Eccentricities`](@ref) struct, return the set of
all vertices whose eccentricity is equal to the graph's radius (that
is, the set of vertices with the smallest eccentricity).

In lieu of an `Eccentricities` struct, one may be (temporarily) created
for use by this function by passing in the corresponding parameters to
[`eccentricities`](@ref) instead. A threaded calculation may be achieved
using an instance of [`Threaded`](@ref) as an argument.

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
center(e::Eccentricities) = findall(e.vals .== e.min)
center(x...) = center(eccentricities(x...))
