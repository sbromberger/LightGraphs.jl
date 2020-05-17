"""
    struct ThreadedMinimalSubset <: VertexSubset

An alias for [`ThreadedRandomSubset`](@ref).
"""
const ThreadedMinimalSubset = ThreadedRandomSubset

function dominating_set(g::AbstractGraph{T}, alg::ThreadedMinimalSubset) where {T<:Integer}
    salg = MinimalSubset(alg.rng)
    return LightGraphs.threaded_generate_reduce(
        g,
        (g::AbstractGraph{T}) -> LightGraphs.VertexSubsets.dominating_set(g, salg),
        (x::Vector{T}, y::Vector{T}) -> length(x)<length(y), alg.reps
    )
end
