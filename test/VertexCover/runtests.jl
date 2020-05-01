using LightGraphs.VertexCover
using LightGraphs.Generators
const LGVC = LightGraphs.VertexCover
const LGGEN = LightGraphs.Generators
const vctestdir = dirname(@__FILE__)

vctests = [

	"degree_vertex_cover.jl",
	"random_vertex_cover.jl"
]

@testset "LightGraphs.VertexCover" begin
    for t in vctests
        tp = joinpath(vctestdir, "$t")
        include(tp)
    end
end

