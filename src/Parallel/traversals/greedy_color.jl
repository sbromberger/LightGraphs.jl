function random_greedy_color(g::AbstractGraph{T}, reps::Integer) where {T <: Integer}
    best = @distributed (LightGraphs.best_color) for i in 1:reps
        seq = shuffle(vertices(g))
        LightGraphs.perm_greedy_color(g, seq)
    end

    return convert(LightGraphs.Coloring{T}, best)
end

greedy_color(g::AbstractGraph{U}; sort_degree::Bool=false, reps::Integer=1) where {U <: Integer} =
    sort_degree ? LightGraphs.degree_greedy_color(g) : Parallel.random_greedy_color(g, reps)
