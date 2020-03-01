using LightGraphs.ShortestPaths

using LightGraphs.Experimental, LightGraphs.Experimental.ShortestPaths
using SparseArrays

using LightGraphs.Experimental.Traversals: NOOPSort
import Base.==
function ==(a::ShortestPaths.AStarResult, b::ShortestPaths.AStarResult)
   return a.path == b.path && a.dist == b.dist
end

const testdir = dirname(@__FILE__)

const tests = [
    "astar.jl"
    "bellman-ford.jl"
    "bfs.jl"
    "desopo-pape.jl"
    "dijkstra.jl"
    "floyd-warshall.jl"
    "johnson.jl"
    "old"
    "runtests.jl"
    "spfa.jl"
]

@testset "LightGraphs.ShortestPaths" begin
    @test !has_negative_weight_cycle(path_graph(5))
    @test !has_negative_weight_cycle(path_digraph(5))
    for t in tests
        tp = joinpath(testdir, "$t")
        include(tp)
    end
end

