"""
    struct DistributedRandomColoring <: DistributedColoringAlgorithm

A struct representing a distributed [`ColoringAlgorithm`](@ref) that colors a graph in
random order using a greedy heuristic, choosing the best coloring out of a number of
such random colorings.

### Optional Arguments
- `niter::Int`: the number of times the random coloring should be repeated (default `1`).
- `rng::AbstractRNG`: a random number generator (default `Random.GLOBAL_RNG`)
"""
struct DistributedRandomColoring{T<:Integer, R<:AbstractRNG} <: DistributedColoringAlgorithm
    niter::T
    rng::R
end
DistributedRandomColoring(; niter=1, rng=GLOBAL_RNG) = DistributedRandomColoring(niter, rng)

function color(g::AbstractGraph{T}, alg::DistributedRandomColoring) where {T <: Integer}
    best = @distributed (best_color) for i in 1:alg.niter
        seq = shuffle(alg.rng, vertices(g))
        color(g, FixedColoring(seq))
    end
    return convert(GraphColoring{T}, best)
end
