"""
    struct RandomColoring <: ColoringAlgorithm

A struct representing a [`ColoringAlgorithm`](@ref) that colors a graph iteratively in
random order using a greedy heuristic, choosing the best coloring out of a number of
such random colorings.

### Optional Arguments
- `niter::Int`: the number of times the random coloring should be repeated (default `1`).
- `rng::AbstractRNG`: a random number generator (default `Random.GLOBAL_RNG`)
"""
struct RandomColoring{T<:Integer, R<:AbstractRNG} <: ColoringAlgorithm
    niter::T
    rng::R
end
RandomColoring(; niter=1, rng=GLOBAL_RNG) = RandomColoring(niter, rng)

function color(g::AbstractGraph{T}, alg::RandomColoring) where {T <: Integer}
    seq = shuffle(alg.rng, vertices(g))
    best = color(g, FixedColoring(seq))

    for i in 2:alg.niter
        shuffle!(alg.rng, seq)
        best = best_color(best, color(g, FixedColoring(seq)))
    end
    return best
end
