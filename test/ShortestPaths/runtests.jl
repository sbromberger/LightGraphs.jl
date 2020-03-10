using LightGraphs.ShortestPaths
using SparseArrays

using LightGraphs.Traversals: NOOPSort
import Base.==
function ==(a::ShortestPaths.AStarResult, b::ShortestPaths.AStarResult)
   return a.path == b.path && a.dist == b.dist
end

const sptestdir = dirname(@__FILE__)

sptests = [

include("astar.jl")
include("bellman-ford.jl")
include("bfs.jl")
include("desopo-pape.jl")
include("dijkstra.jl")
include("distributed-dijkstra.jl")
include("floyd-warshall.jl")
include("johnson.jl")
include("distributed-bellman-ford.jl")
include("distributed-johnson.jl")
include("spfa.jl")
include("threaded-bfs.jl")
include("threaded-floyd-warshall.jl")
]

@testset "LightGraphs.ShortestPaths" begin
    @test !has_negative_weight_cycle(path_graph(5))
    @test !has_negative_weight_cycle(path_digraph(5))
    for t in sptests
        tp = joinpath(sptestdir, "$t")
        include(tp)
    end
end

