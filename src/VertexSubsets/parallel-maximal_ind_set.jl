"""
    struct ParallelMaximalSubset <: VertexSubset

An alias for [`ParallelRandomSubset`](@ref).
"""
const ParallelMaximalSubset = ParallelRandomSubset

function independent_set(g::AbstractGraph{T}, alg::ParallelMaximalSubset) where {T<:Integer}
    salg = MaximalSubset(alg.rng)
    return LightGraphs.distributed_generate_reduce(
        g,
        (g::AbstractGraph{T}) -> LightGraphs.VertexSubsets.independent_set(g, salg),
        (x::Vector{T}, y::Vector{T}) -> length(x)<length(y), alg.reps
    )
end
