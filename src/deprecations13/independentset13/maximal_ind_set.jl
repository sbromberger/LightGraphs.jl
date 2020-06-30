Base.@deprecate_binding MaximalIndependentSet LightGraphs.VertexSubsets.RandomSubset

function independent_set(
    g::AbstractGraph{T},
    alg::MaximalIndependentSet;
    seed::Int=-1
    ) where T <: Integer

    Base.depwarn("`independent_set` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexSubsets.independent_set`.", :independent_set)
    rng = LightGraphs.getRNG(seed)
    LightGraphs.VertexSubsets.independent_set(g, LightGraphs.VertexSubsets.RandomSubset(rng=rng))
end
