Base.@deprecate_binding MinimalDominatingSet LightGraphs.VertexSubsets.MinimalSubset
function dominating_set(g::AbstractGraph, ::LightGraphs.MinimalDominatingSet; seed=-1)
    Base.depwarn("`dominating_set` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexSubsets.dominating_set`.", :dominating_set)
    rng = LightGraphs.getRNG(seed)
    alg = LightGraphs.VertexSubsets.MinimalSubset(rng=rng)
    LightGraphs.VertexSubsets.dominating_set(g, alg)
end
