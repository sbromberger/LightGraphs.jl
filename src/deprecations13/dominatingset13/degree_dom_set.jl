Base.@deprecate_binding DegreeDominatingSet LightGraphs.VertexSubsets.DegreeSubset

function dominating_set(g::AbstractGraph, ::LightGraphs.DegreeDominatingSet)
    Base.depwarn("`dominating_set` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexSubsets.dominating_set`.", :dominating_set)
    LightGraphs.VertexSubsets.dominating_set(g, LightGraphs.VertexSubsets.DegreeSubset())
end
