using LightGraphs.Biconnectivity
using LightGraphs.SimpleGraphsCore: SimpleEdge

const LBC = LightGraphs.Biconnectivity

const biconntestdir = dirname(@__FILE__)

const biconntests = [
    "articulation.jl",
    "biconnect.jl",
    "bridge.jl"
]

@testset "LightGraphs.Biconnectivity" begin
    for t in biconntests
        tp = joinpath(biconntestdir, "$t")
        include(tp)
    end
end
