# TODO 2.0.0: Remove this file
function random_greedy_color(g::AbstractGraph{T}, reps::Integer) where {T <: Integer}
    Base.depwarn("`Parallel.random_greedy_color` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.greedy_color`.", :random_greedy_color)
    LightGraphs.Traversals.greedy_color(g, LightGraphs.Traversals.ThreadedRandomColoring(niter=reps))
end

greedy_color(g::AbstractGraph{U}; sort_degree::Bool=false, reps::Integer=1) where {U <: Integer} =
    sort_degree ? LightGraphs.degree_greedy_color(g) : Parallel.random_greedy_color(g, reps)
