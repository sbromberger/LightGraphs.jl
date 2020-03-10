"""
    vertex_cover(g, reps, RandomVertexCover(); parallel=:threads)

Perform [`LightGraphs.vertex_cover(g, RandomVertexCover())`](@ref) `reps` times in parallel
and return the solution with the fewest vertices.

### Optional Arguements
- `parallel=:threads`: If `parallel=:distributed` then the multiprocessor implementation is
used. This implementation is more efficient if `reps` is large.
"""
vertex_cover(
    g::AbstractGraph{T},
    reps::Integer,
    alg::RandomVertexCover;
    parallel = :threads,
) where {T <: Integer} = LightGraphs.Parallel.generate_reduce(
    g,
    (g::AbstractGraph{T}) -> LightGraphs.vertex_cover(g, alg),
    (x::Vector{T}, y::Vector{T}) -> length(x) < length(y),
    reps;
    parallel = parallel,
)
