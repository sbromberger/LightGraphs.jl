using LightGraphs
using LightGraphs.Parallel

@test length(description()) > 1

tests = [
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/pagerank",
    "centrality/radiality",
    "centrality/stress",
    "distance",
    "shortestpaths/dijkstra",
    "shortestpaths/johnson"
]

@testset "LightGraphs.Parallel" begin
    for t in tests
        tp = joinpath(testdir, "parallel", "$(t).jl")
        include(tp)
    end
end
