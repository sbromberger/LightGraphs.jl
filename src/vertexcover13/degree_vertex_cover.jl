export DegreeVertexCover
struct DegreeVertexCover end
function vertex_cover(
    g::AbstractGraph{T},
    alg::DegreeVertexCover
    ) where T <: Integer

    Base.depwarn("`vertex_cover` is deprecated. Equivalent functionality has been moved to `LightGraphs.VertexCover.vertex_cover`.", :vertex_cover)
    LightGraphs.VertexCover.vertex_cover(g, LightGraphs.VertexCover.DegreeVertexCover())
end
