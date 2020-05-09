using LightGraphs.VertexSubsets
using LightGraphs.Generators
const LGVS = LightGraphs.VertexSubsets
const LGGEN = LightGraphs.Generators
const vstestdir = dirname(@__FILE__)

vstests = [

	"degree_vertex_cover.jl",
	"random_vertex_cover.jl",
	"degree_dom_set.jl",
	"minimal_dom_set.jl",
]

@testset "LightGraphs.VertexSubsets" begin
    for t in vstests
        tp = joinpath(vstestdir, "$t")
        include(tp)
    end
end

