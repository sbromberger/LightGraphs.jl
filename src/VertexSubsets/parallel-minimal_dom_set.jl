"""
    struct ParallelMinimalSubset <: VertexSubset

An alias for [`ParallelRandomSubset`](@ref).
"""
const ParallelMinimalSubset = ParallelRandomSubset

function dominating_set(g::AbstractGraph{T}, alg::ParallelMinimalSubset) where {T<:Integer}
    salg = MinimalSubset(alg.rng)
    return LightGraphs.distributed_generate_reduce(
        g,
        (g::AbstractGraph{T}) -> LightGraphs.VertexSubsets.dominating_set(g, salg),
        (x::Vector{T}, y::Vector{T}) -> length(x)<length(y), alg.reps
    )
end
