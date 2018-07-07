"""
    parallel_generate_min_set(g, gen_func, Reps)

Generate `Reps` set using `gen_func(g)` and return the smallest set.
"""
parallel_generate_min_set(g::AbstractGraph{T}, gen_func, Reps::Integer) where T<: Integer =
mapreduce(gen_func, (x, y)->length(x)<length(y) ? x : y, Iterators.repeated(g, Reps))

"""
    parallel_generate_max_set(g, gen_func, Reps)

Generate `Reps` set using `gen_func(g)` and return the largest set.
"""
parallel_generate_max_set(g::AbstractGraph{T}, gen_func, Reps::Integer) where T<: Integer =
mapreduce(gen_func, (x, y)->length(x)>length(y) ? x : y, Iterators.repeated(g, Reps))
