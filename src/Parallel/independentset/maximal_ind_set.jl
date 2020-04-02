"""
    independent_set(g, reps, MaximalIndependentSet(); parallel=:threads)

Perform [`LightGraphs.independent_set(g, MaximalIndependentSet())`](@ref) `reps` times in parallel
and return the solution with the most vertices.

### Optional Arguements
- `parallel=:threads`: If `parallel=:distributed` then the multiprocessor implementation is
used. This implementation is more efficient if `reps` is large.
"""
independent_set(g::AbstractGraph{T}, reps::Integer, alg::MaximalIndependentSet; parallel=:threads) where T <: Integer =
LightGraphs.Parallel.generate_reduce(g, (g::AbstractGraph{T})->LightGraphs.independent_set(g, alg),
(x::Vector{T}, y::Vector{T})->length(x)>length(y), reps; parallel=parallel)
