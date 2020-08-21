function vertex_cover(g::AbstractGraph{T}, reps::Integer, alg::RandomVertexCover; parallel=:threads, seed=-1) where T <: Integer
    Base.depwarn("`vertex_cover` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexSubsets.vertex_cover`.", :vertex_cover)
    rng = LightGraphs.getRNG(seed)
    alg = parallel == :threads ?  LightGraphs.VertexSubsets.ThreadedRandomSubset(reps, rng=rng) : LightGraphs.VertexSubsets.DistributedRandomSubset(reps, rng=rng)
    LightGraphs.VertexSubsets.vertex_cover(g, alg)
end
