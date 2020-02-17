# Developing Alternate Graph Types

This section is designed to guide developers who wish to write their own graph structures.

All LightGraphs functions rely on a standard API to function. As long as your graph structure is a subtype of
[`AbstractGraph`](@ref) and implements the following API functions with the given return values, all functions
within the LightGraphs package should just work:

- [`edges`](@ref)
- [Base.eltype](https://docs.julialang.org/en/latest/base/collections/#Base.eltype)
- [`edgetype`](@ref) (example: `edgetype(g::CustomGraph) = LightGraphs.SimpleEdge{eltype(g)})`)
- [`has_edge`](@ref)
- [`has_vertex`](@ref)
- [`inneighbors`](@ref)
- [`ne`](@ref)
- [`nv`](@ref)
- [`outneighbors`](@ref)
- [`vertices`](@ref)
- [`is_directed`](@ref): Note that since LightGraphs uses traits to determine directedness, `is_directed` for a `CustomGraph` type
should be implemented with **both** of the following signatures:
  - `is_directed(::Type{CustomGraph})::Bool` (example: `is_directed(::Type{<:CustomGraph}) = false`)
  - `is_directed(g::CustomGraph)::Bool`
- [`zero`](@ref)

If the graph structure is designed to represent weights on edges, the [`weights`](@ref) function should also be defined.
Note that the output does not necessarily have to be a dense matrix, but it must be a subtype of `AbstractMatrix{<:Real}` and indexable via `[u, v]`.

#### Note on inheriting from AbstractSimpleGraph

Every subtype of AbstractSimpleGraph must return neighbors in ascending order.
