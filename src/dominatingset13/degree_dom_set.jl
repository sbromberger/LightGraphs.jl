struct DegreeDominatingSet end
export DegreeDominatingSet
function dominating_set(g::AbstractGraph, ::LightGraphs.DegreeDominatingSet)
    Base.depwarn("`dominating_set` is deprecated. Equivalent functionality has been moved to `LightGraphs.Domination.dominating_set`.", :dominating_set)
    LightGraphs.Domination.dominating_set(g, LightGraphs.Domination.DegreeDominatingSet())
end
