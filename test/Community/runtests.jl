using LightGraphs.Community

const LCOM = LightGraphs.Community

const communitytestdir = dirname(@__FILE__)

communitytests = [
	"cliques.jl",
	"clustering.jl",
	"communities.jl",
	"core-periphery.jl",
	"modularity.jl",
	"triangle_count.jl",
]

@testset "LightGraphs.Community" begin
    for t in communitytests
        tp = joinpath(communitytestdir, "$t")
        include(tp)
    end
end

