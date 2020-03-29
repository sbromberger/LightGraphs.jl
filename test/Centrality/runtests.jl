using LightGraphs.Centrality
const LCENT = LightGraphs.Centrality

const centralitydir = dirname(@__FILE__)

centralitytests = [
	"betweenness.jl",
	"closeness.jl",
	"degree.jl",
	"distributed-betweenness.jl",
	"distributed-closeness.jl",
	"distributed-radiality.jl",
	"distributed-stress.jl",
	"eigenvector.jl",
	"katz.jl",
	"pagerank.jl",
	"radiality.jl",
	"stress.jl",
	"threaded-betweenness.jl",
	"threaded-closeness.jl",
	"threaded-pagerank.jl",
	"threaded-radiality.jl",
	"threaded-stress.jl"
]

@testset "LightGraphs.Centrality" begin
    for t in centralitytests
        tp = joinpath(centralitydir, "$t")
        include(tp)
    end
end

