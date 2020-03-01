using LightGraphs.ShortestPaths
using SparseArrays

using LightGraphs.Traversals: NOOPSort
import Base.==
function ==(a::ShortestPaths.AStarResult, b::ShortestPaths.AStarResult)
   return a.path == b.path && a.dist == b.dist
end

const sptestdir = dirname(@__FILE__)

sptests = [
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
    for t in sptests
        println("shortest paths: testing $t")
        tp = joinpath(sptestdir, "$t")
        include(tp)
    end
end

