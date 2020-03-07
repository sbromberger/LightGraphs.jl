using LightGraphs.Traversals

const LT = LightGraphs.Traversals

# using LightGraphs.ShortestPaths: parents, shortest_paths

const travtestdir = dirname(@__FILE__)

travtests = [
    "breadthfirst.jl"
    "threadedbreadthfirst.jl"
    "bipartition.jl"
    "depthfirst.jl"
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

