using LightGraphs
using LightGraphs.Parallel
using Base.Threads: @threads, Atomic
@test length(description()) > 1

tests = [
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/pagerank",
    "centrality/radiality",
    "centrality/stress",
    "distance",
    "shortestpaths/bellman-ford",
    "shortestpaths/dijkstra",
    "shortestpaths/floyd-warshall",
    "shortestpaths/johnson",
    "traversals/bfs",
    "traversals/gdistances",
    "traversals/greedy_color"
]

@testset "LightGraphs.Parallel" begin
    for t in tests
        tp = joinpath(testdir, "parallel", "$(t).jl")
        include(tp)
    end
end
