using LightGraphs.Coloring

const LCOL = LightGraphs.Coloring

# using LightGraphs.ShortestPaths: parents, shortest_paths

const coloringtestdir = dirname(@__FILE__)

coloringtests = [
    "bipartition.jl"
    "greedy_color.jl"
    "threaded-greedy_color.jl"
]

@testset "LightGraphs.Coloring" begin
    for t in coloringtests
        tp = joinpath(coloringtestdir, "$t")
        include(tp)
    end
end
