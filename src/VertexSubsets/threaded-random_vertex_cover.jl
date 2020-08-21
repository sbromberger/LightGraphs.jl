function vertex_cover(g::AbstractGraph{T}, alg::ThreadedRandomSubset) where {T<:Integer}
    salg = RandomSubset(alg.rng)
    return LightGraphs.threaded_generate_reduce(
        g,
        (g::AbstractGraph{T}) -> LightGraphs.VertexSubsets.vertex_cover(g, salg),
        (x::Vector{T}, y::Vector{T}) -> length(x)<length(y), alg.reps
    )
end

