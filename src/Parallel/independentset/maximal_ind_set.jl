function independent_set(g::AbstractGraph{T}, reps::Integer, alg::MaximalIndependentSet; parallel=:threads, seed=-1) where T <: Integer
    Base.depwarn("`independent_set` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexSubsets.independent_set`.", :independent_set)
    rng = LightGraphs.getRNG(seed)
    alg = parallel == :threads ?  LightGraphs.VertexSubsets.ThreadedMaximalSubset(reps, rng=rng) : LightGraphs.VertexSubsets.ParallelMaximalSubset(reps, rng=rng)
    LightGraphs.VertexSubsets.independent_set(g, alg)
end
