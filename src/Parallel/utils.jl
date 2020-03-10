"""
    generate_reduce(g, gen_func, comp, reps; parallel=:threads)

Compute `gen_func(g)` `reps` times and return the instance `best` for which
`comp(best, v)` is true where `v` is all the other instances of `gen_func(g)`.

For example, `comp(x, y) = length(x) < length(y) ? x : y` then instance with the smallest
length will be returned.
"""
generate_reduce(
    g::AbstractGraph{T},
    gen_func::Function,
    comp::Comp,
    reps::Integer;
    parallel = :threads,
) where {T <: Integer, Comp} =
    parallel == :threads ? threaded_generate_reduce(g, gen_func, comp, reps) :
    distr_generate_reduce(g, gen_func, comp, reps)

"""
    distr_generate_min_set(g, gen_func, comp, reps)

Distributed implementation of [`LightGraphs.generate_reduce`](@ref).
"""
function distr_generate_reduce(
    g::AbstractGraph{T},
    gen_func::Function,
    comp::Comp,
    reps::Integer,
) where {T <: Integer, Comp}
    # Type assert required for type stability
    min_set::Vector{T} = @distributed ((x, y) -> comp(x, y) ? x : y) for _ in 1:reps
        gen_func(g)
    end
    return min_set
end

"""
    threaded_generate_reduce(g, gen_func, comp reps)

Multi-threaded implementation of [`LightGraphs.generate_reduce`](@ref).
"""
function threaded_generate_reduce(
    g::AbstractGraph{T},
    gen_func::Function,
    comp::Comp,
    reps::Integer,
) where {T <: Integer, Comp}
    n_t = Base.Threads.nthreads()
    is_undef = ones(Bool, n_t)
    min_set = [Vector{T}() for _ in 1:n_t]
    Base.Threads.@threads for _ in 1:reps
        t = Base.Threads.threadid()
        next_set = gen_func(g)
        if is_undef[t] || comp(next_set, min_set[t])
            min_set[t] = next_set
            is_undef[t] = false
        end
    end

    min_ind = 0
    for i in filter((j) -> !is_undef[j], 1:n_t)
        if min_ind == 0 || comp(min_set[i], min_set[min_ind])
            min_ind = i
        end
    end

    return min_set[min_ind]
end
