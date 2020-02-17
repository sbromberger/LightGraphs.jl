# Developing Alternate Graph Types

This section is designed to guide developers who wish to write their own graph structures.

All LightGraphs functions rely on a standard API to function. As long as your graph structure is a subtype of
[`AbstractGraph`](@ref) and implements the following API functions, all functions
within the LightGraphs package should just work:

- [`edges`](@ref)
- [Base.eltype](https://docs.julialang.org/en/latest/base/collections/#Base.eltype)
- [`edgetype`](@ref) (example: `edgetype(g::CustomGraph) = LightGraphs.SimpleEdge{eltype(g)})`)
- [`has_edge`](@ref)
- [`inneighbors`](@ref)
- [`ne`](@ref)
- [`nv`](@ref)
- [`outneighbors`](@ref)
- [`zero`](@ref)
- [`is_directed`](@ref): Note that since LightGraphs uses traits to determine directedness, `is_directed` for a `CustomGraph` type
must be implemented with the following signature:
  - `is_directed(::Type{CustomGraph})::Bool` (example: `is_directed(::Type{<:CustomGraph}) = false`)
The following signature is optional:
  - `is_directed(g::CustomGraph)::Bool`

If the graph structure is designed to represent weights on edges, the [`weights`](@ref)
function should also be defined. Note that the output does not necessarily have to be a
dense matrix, but it must be a subtype of `AbstractMatrix{<:Real}` and indexable via `[u, v]`.

#### Contiguous vertices

Some LightGraphs functions work under the assumption that the vertices are
contiguous integer from `one(eltype(g))` to `nv(g)`.
For graph types which do *not* respect this assumption, the method [`has_contiguous_vertices`](@ref)
should be implemented and set to false.
The following methods, which use this assumption when possible, should also be redefined:

- [`has_vertex`](@ref)
- [`vertices`](@ref)


#### Inheriting from AbstractSimpleGraph

`AbstractSimpleGraph` is the supertype of both `SimpleGraph` and `SimpleDiGraph`.
Every subtype of `AbstractSimpleGraph` must return neighbors in ascending order.
