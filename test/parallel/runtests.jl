using LightGraphs
using LightGraphs.Parallel

@test length(description()) > 1

tests = [
    "distance",
    "shortestpaths/dijkstra",
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/radiality",
    "centrality/stress",
]

@testset "LightGraphs.Parallel" begin
    for t in tests
        tp = joinpath(testdir, "parallel", "$(t).jl")
        include(tp)
    end
end
