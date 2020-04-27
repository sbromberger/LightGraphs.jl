using LightGraphs.Domination
using LightGraphs.Generators
using LightGraphs.SimpleGraphs

const LGDOM = LightGraphs.Domination
const LGGEN = LightGraphs.Generators

const domtestdir = dirname(@__FILE__)

domtests = [
	"degree_dom_set.jl",
	"minimal_dom_set.jl",
]

@testset "LightGraphs.Domination" begin
    for t in domtests
        tp = joinpath(domtestdir, "$t")
        include(tp)
    end
end
