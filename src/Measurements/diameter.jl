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
_associated_extreme(::Diameter) = maximum
