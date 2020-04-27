struct MinimalDominatingSet end
export MinimalDominatingSet
function dominating_set(g::AbstractGraph, ::LightGraphs.MinimalDominatingSet; seed=-1)
    Base.depwarn("`dominating_set` is deprecated. Equivalent functionality has been moved to `LightGraphs.Domination.dominating_set`.", :dominating_set)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    alg = LightGraphs.Domination.MinimalDominatingSet(rng=rng)
    LightGraphs.Domination.dominating_set(g, alg)
end
