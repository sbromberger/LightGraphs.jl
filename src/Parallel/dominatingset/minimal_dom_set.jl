function dominating_set(g::AbstractGraph{T}, reps::Integer, alg::MinimalDominatingSet; parallel=:threads, seed=-1) where T <: Integer
    Base.depwarn("`dominating_set` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexSubsets.dominating_set`.", :dominating_set)
    rng = LightGraphs.getRNG(seed)
    alg = parallel == :threads ?  LightGraphs.VertexSubsets.ThreadedMinimalSubset(reps, rng=rng) : LightGraphs.VertexSubsets.ParallelMinimalSubset(reps, rng=rng)
    LightGraphs.VertexSubsets.dominating_set(g, alg)
end
