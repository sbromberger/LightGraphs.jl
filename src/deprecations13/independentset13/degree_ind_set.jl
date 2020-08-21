Base.@deprecate_binding DegreeIndependentSet LightGraphs.VertexSubsets.DegreeSubset

function independent_set(
    g::AbstractGraph{T},
    alg::DegreeIndependentSet
    ) where T <: Integer

    Base.depwarn("`independent_set` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexSubsets.independent_set`.", :independent_set)
    LightGraphs.VertexSubsets.independent_set(g, LightGraphs.VertexSubsets.DegreeSubset())
end
