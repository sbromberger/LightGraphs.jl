function independent_set(g::AbstractGraph{T}, alg::DistributedRandomSubset) where {T<:Integer}
    salg = RandomSubset(alg.rng)
    return LightGraphs.distributed_generate_reduce(
        g,
        (g::AbstractGraph{T}) -> LightGraphs.VertexSubsets.independent_set(g, salg),
        (x::Vector{T}, y::Vector{T}) -> length(x)>length(y), alg.reps
    )
end
