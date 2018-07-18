"""
    generate_min_set(g, gen_func, Reps)

Generate a vector `Reps` times using `gen_func(g)` and return the vector with the least elements.
"""
generate_min_set(g::AbstractGraph{T}, gen_func, Reps::Integer) where T<: Integer =
mapreduce(gen_func, (x, y)->length(x)<length(y) ? x : y, Iterators.repeated(g, Reps))

"""
    generate_max_set(g, gen_func, Reps)

Generate a vector `Reps` times using `gen_func(g)` and return the vector with the most elements.
"""
generate_max_set(g::AbstractGraph{T}, gen_func, Reps::Integer) where T<: Integer =
mapreduce(gen_func, (x, y)->length(x)>length(y) ? x : y, Iterators.repeated(g, Reps))

"""
    generate_min_colors(g, gen_func, Reps)

Generate a [`LightGraphs.coloring`](@ref) `Reps` times using `gen_func(g)` and 
return the [`LightGraphs.coloring`](@ref) with the least colors.
"""
generate_min_colors(g::AbstractGraph{T}, gen_func, Reps::Integer) where T<: Integer =
mapreduce(gen_func, (c1, c2)->c1.num_colors < c2.num_colors ? c1 : c2, Iterators.repeated(g, Reps))