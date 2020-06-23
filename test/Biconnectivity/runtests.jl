using LightGraphs.Biconnectivity

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