using LightGraphs.VertexSubsets
export RandomVertexCover
struct RandomVertexCover end

function vertex_cover(
    g::AbstractGraph{T},
    alg::RandomVertexCover;
    seed::Int=-1
    ) where T <: Integer

    Base.depwarn("`vertex_cover` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexSubsets.vertex_cover`.", :vertex_cover)
    rng = LightGraphs.getRNG(seed)
    LightGraphs.VertexSubsets.vertex_cover(g, LightGraphs.VertexSubsets.RandomSubset(rng=rng))
end
