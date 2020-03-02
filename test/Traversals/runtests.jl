using LightGraphs.Traversals
using LightGraphs.ShortestPaths: parents, shortest_paths

const travtestdir = dirname(@__FILE__)

travtests = [
    "bfs.jl"
    "bipartition.jl"
    "dfs.jl"
    "diffusion.jl"
    "greedy_color.jl"
    "maxadjvisit.jl"
    "randomwalks.jl"
]

@testset "LightGraphs.Traversals" begin
    for t in travtests
        tp = joinpath(travtestdir, "$t")
        include(tp)
    end
end

