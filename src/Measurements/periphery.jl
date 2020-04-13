module Measurements

using LightGraphs
using LightGraphs.ShortestPaths:ShortestPathAlgorithm, Dijkstra, BFS, shortest_paths, distances

"""
    abstract type GraphMeasurement

A structure representing a common measurement of a graph.
"""
abstract type GraphMeasurement end

"""
    struct Diameter <: GraphMeasurement

A structure representing a calculation of a graph's diameter.
The diameter of a graph is its maximum [`eccentricity`](@ref).

### Optional Arguments
- `eccentricities::Vector{<:Real}` - precomputed [eccentricities](@ref eccentricity), if available,
will be used instead of a separate calculation.

# Examples
```jldoctest
julia> using LightGraphs

julia> metric(star_graph(5), Diameter())
2

julia> metric(path_graph(5), Diameter())
4
```
"""
struct Diameter{T<:Union{Vector{<:Real}, Nothing}} <: GraphMeasurement
    eccentricities::T
end

Diameter(;eccentricities=nothing) = Diameter(eccentricities)

"""
    struct Radius <: GraphMeasurement

A structure representing a calculation of a graph's radius. The
radius of a graph is its minimum [`eccentricity`](@ref).

### Optional Arguments
- `eccentricities::Vector{<:Real}` - precomputed [eccentricities](@ref eccentricity), if available,
will be used instead of a separate calculation.

# Examples
```jldoctest
julia> using LightGraphs, LightGraphs.Measurements

julia> metric(star_graph(5), Radius())
1

julia> metric(path_graph(5), Radius())
2
```
"""
struct Radius{T<:Union{Vector{<:Real}, Nothing}} <: GraphMeasurement
    eccentricities::T
end

Radius(;eccentricities=nothing) = Radius(eccentricities)

"""
    metric(g::AbstractGraph[, vs[, distmx]], measurement::GraphMeasurement)

Return the result of the [graph measurement](@ref GraphMeasurement) specified
by `measurement` on the graph `g`. If `vs` or `distmx` is specified, the eccentricity
calculation will be performed explicitly; if both are omitted, the eccentricies
are assumed to be contained within `measurement`.
"""
function metric end

_associated_extreme(::Diameter) = maximum
_associated_extreme(::Radius) = minimum

function _metric(g::AbstractGraph, vs, distmx::AbstractMatrix, gm::GraphMeasurement, use_eccs::Bool, use_dists::Bool)
    eccs = 
        if use_eccs
            gm.eccentricities
        elseif use_dists
            eccentricities(g, vs, distmx)
        elseif vs == 0
            eccentricity(g)
        else
            eccentricity(g, vs)
        end
    return _associated_extreme(gm)(eccs)
end

metric(g::AbstractGraph, vs, distmx::AbstractMatrix, gm::GraphMeasurement) =
    _metric(g, vs, distmx, gm, false, true)

metric(g::AbstractGraph, vs, gm::GraphMeasurement) = _metric(g, vs, zeros(0,0), gm, false, false)
metric(g::AbstractGraph, gm::GraphMeasurement) = _metric(g, 0, zeros(0,0), gm, !isnothing(gm.eccentricities), false)

"""
    abstract type VertexSubset

A type representing a subset of vertices induced by a graph measurement.
"""
abstract type VertexSubset end

"""
    struct Periphery <: VertexSubset

A structure representing a calculation of a graph's periphery.
The periphery of a graph is the set of all vertices whose [`eccentricity`](@ref) is
equal to the graph's [diameter](@ref Diameter) (that is, the set of vertices with the
largest [`eccentricity`](@ref)).

### Optional Arguments
- `eccentricities::Vector{<:Real}` - precomputed [eccentricities](@ref eccentricity), if available,
will be used instead of a separate calculation.

# Examples
```jldoctest
julia> using LightGraphs

julia> vertex_subset(star_graph(5), Periphery())
4-element Array{Int64,1}:
 2
 3
 4
 5

 julia> vertex_subset(path_graph(5), Periphery())
2-element Array{Int64,1}:
 1
 5
```
"""
struct Periphery{T<:Union{Vector{<:Real}, Nothing}} <: VertexSubset
    eccentricities::T
end
Periphery(;eccentricities=nothing) = Periphery(eccentricities)

"""
    struct Center <: VertexSubset

A structure representing a calculation of a graph's center.
The center of a graph is the set of all vertices whose [`eccentricity`](@ref) is
equal to the graph's [radius](@ref Radius) (that is, the set of vertices with the
smallest [`eccentricity`](@ref)).

### Optional Arguments
- `eccentricities::Vector{<:Real}` - precomputed [eccentricities](@ref eccentricity), if available,
will be used instead of a separate calculation.

# Examples
```jldoctest
julia> using LightGraphs, LightGraphs.Measurements

julia> vertex_subset(star_graph(5), Center())
1-element Array{Int64,1}:
 1

julia> vertex_subset(path_graph(5), Center())
1-element Array{Int64,1}:
 3
```
"""
struct Center{T<:Union{Vector{<:Real}, Nothing}} <: VertexSubset
    eccentricities::T
end
Center(;eccentricities=nothing) = Center(eccentricities)

"""
    vertex_subset(g::AbstractGraph[, vs][, distmx], vsubset::VertexSubset)

Return the result of the [vertex subset](@ref VertexSubset) specified
by `vsubset` on the graph `g` with optional distances specified by `distmx`.
If `vs` is specified, the eccentricity calculation will be performed
explicitly; if `vs` is omitted, the eccentricies are assumed to be contained
within `vsubset`.
"""
function vertex_subset end

_associated_metric(::Periphery) = Diameter
_associated_metric(::Center) = Radius

function _vertex_subset(g::AbstractGraph, vs, distmx::AbstractMatrix, vsubset::VertexSubset, use_eccs::Bool, use_dists::Bool)
    eccs = 
        if use_eccs
            vsubset.eccentricities
        elseif use_dists
            eccentricity(g, vs, distmx)
        else
            eccentricity(g, vs)
        end
    m = metric(g, eccs, _associated_metric(vsubset)())
    return findall(x==m, eccs)
end

vertex_subset(g::AbstractGraph, vs, distmx::AbstractMatrix, vsubset::VertexSubset) = 
    _vertex_subset(g, vs, distmx, vsubset, false, true)

vertex_subset(g::AbstractGraph, vs, vsubset::VertexSubset) =
    _vertex_subset(g, vs, zeros(0,0), vsubset, false, false)

vertex_subset(g::AbstractGraph, vsubset::VertexSubset) =
   _vertex_subset(g, 0, zeros(0,0), vsubset, true, false)

end # module
