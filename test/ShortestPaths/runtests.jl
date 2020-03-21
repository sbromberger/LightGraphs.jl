using SparseArrays
using LightGraphs.ShortestPaths
using LightGraphs.Traversals
using LightGraphs.Traversals: NOOPSort

const sptestdir = dirname(@__FILE__)

sptests = [
    "astar.jl",
    "bellman-ford.jl",
    "bfs.jl",
    "desopo-pape.jl",
    "dijkstra.jl",
    "distributed-dijkstra.jl",
    "floyd-warshall.jl",
    "johnson.jl",
    "distributed-bellman-ford.jl",
    "distributed-johnson.jl",
    "spfa.jl",
    "threaded-bfs.jl",
    "threaded-floyd-warshall.jl"
]

@testset "LightGraphs.ShortestPaths" begin
    @test !ShortestPaths.has_negative_weight_cycle(path_graph(5))
    @test !ShortestPaths.has_negative_weight_cycle(path_digraph(5))
    for t in sptests
        tp = joinpath(sptestdir, "$t")
        include(tp)
    end
end

