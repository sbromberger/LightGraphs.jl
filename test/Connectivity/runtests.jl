using LightGraphs.ShortestPaths
using LightGraphs.Traversals

const LC = LightGraphs.Connectivity

const conntestdir = dirname(@__FILE__)

const conntests = [
    "connectivity.jl",
    "strong.jl",
    "weak.jl"
]

@testset "LightGraphs.Connectivity" begin
    for t in conntests
        tp = joinpath(conntestdir, "$t")
        include(tp)
    end
end
