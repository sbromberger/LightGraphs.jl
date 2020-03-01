using LightGraphs
using LightGraphs.Parallel
using LightGraphs.ShortestPaths
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
    "traversals/greedy_color",
    "dominatingset/minimal_dom_set",
    "independentset/maximal_ind_set",
    "vertexcover/random_vertex_cover",
    "utils"
]

@testset "LightGraphs.Parallel" begin
    for t in tests
        tp = joinpath(testdir, "Parallel", "$(t).jl")
        include(tp)
    end
end
