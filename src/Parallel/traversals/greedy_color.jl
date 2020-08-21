# TODO 2.0.0: Remove this file
function random_greedy_color(g::AbstractGraph{T}, reps::Integer) where {T <: Integer}
    Base.depwarn("`Parallel.random_greedy_color` is deprecated. Equivalent functionality has been moved to `LightGraphs.Coloring.color`.", :random_greedy_color)
    LightGraphs.Coloring.color(g, LightGraphs.Coloring.DistributedRandomColoring(niter=reps))
end
