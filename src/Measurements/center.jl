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
_associated_metric(::Center) = Radius

end # module
