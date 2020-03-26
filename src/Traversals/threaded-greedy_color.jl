abstract type ParallelColoringAlgorithm <: ColoringAlgorithm end
abstract type ThreadedColoringAlgorithm <: ParallelColoringAlgorithm end

"""
    struct ThreadedRandomColoring <: ThreadedColoringAlgorithm

A struct representing a threaded [`ColoringAlgorithm`](@ref) that colors a graph in
random order using a greedy heuristic, choosing the best coloring out of a number of
such random colorings.

### Optional Arguments
- `niter::Int`: the number of times the random coloring should be repeated (default `1`).
- `rng::AbstractRNG`: a random number generator (default `Random.GLOBAL_RNG`)
"""
struct ThreadedRandomColoring{T<:Integer, R<:AbstractRNG} <: ThreadedColoringAlgorithm
    niter::T
    rng::R
end
ThreadedRandomColoring(; niter=1, rng=GLOBAL_RNG) = ThreadedRandomColoring(niter, rng)

function greedy_color(g::AbstractGraph{T}, alg::ThreadedRandomColoring) where {T <: Integer}
    best = @distributed (best_color) for i in 1:alg.niter
        seq = shuffle(alg.rng, vertices(g))
        greedy_color(g, FixedColoring(seq))
    end
    return convert(Coloring{T}, best)
end
