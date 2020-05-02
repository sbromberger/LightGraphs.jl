export RandomVertexCover
struct RandomVertexCover end

function vertex_cover(
    g::AbstractGraph{T},
    alg::RandomVertexCover;
    seed::Int=-1
    ) where T <: Integer

    Base.depwarn("`vertex_cover` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexCover.vertex_cover`.", :vertex_cover)
    rng = LightGraphs.getRNG(seed)
    LightGraphs.VertexCover.vertex_cover(g, LightGraphs.VertexCover.RandomVertexCover(rng=rng))
end
