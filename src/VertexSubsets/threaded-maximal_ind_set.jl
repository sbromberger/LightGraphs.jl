"""
    struct ThreadedMaximalSubset <: VertexSubset

An alias for [`ThreadedRandomSubset`](@ref).
"""
const ThreadedMaximalSubset = ThreadedRandomSubset

function independent_set(g::AbstractGraph{T}, alg::ThreadedMaximalSubset) where {T<:Integer}
    salg = MaximalSubset(alg.rng)
    return LightGraphs.threaded_generate_reduce(
        g,
        (g::AbstractGraph{T}) -> LightGraphs.VertexSubsets.independent_set(g, salg),
        (x::Vector{T}, y::Vector{T}) -> length(x)<length(y), alg.reps
    )
end

