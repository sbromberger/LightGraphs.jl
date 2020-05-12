"""
    struct ThreadedRandomSubset <: VertexSubset

A struct representing an algorithm to calculate the minimum [dominating set](https://en.wikipedia.org/wiki/Dominating_set)
of a graph performing `reps` times in parallel using threads, returning the minimal result.

### Required Fields
`reps::Integer`: the number of times to perform the calculation.

### Optional Arguments
- `rng<:AbstractRNG`: override default random number generator (`GLOBAL_RNG`).
"""
struct ThreadedRandomSubset{R<:AbstractRNG} <: VertexSubset
    reps::Int
    rng::R
end
ThreadedRandomSubset(reps::Int; rng=GLOBAL_RNG) = ThreadedRandomSubset(reps, rng)

function vertex_cover(g::AbstractGraph{T}, alg::ThreadedRandomSubset) where {T<:Integer}
    salg = RandomSubset(alg.rng)
    return LightGraphs.threaded_generate_reduce(
        g,
        (g::AbstractGraph{T}) -> LightGraphs.VertexSubsets.vertex_cover(g, salg),
        (x::Vector{T}, y::Vector{T}) -> length(x)<length(y), alg.reps
    )
end

