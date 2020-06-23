using LightGraphs.Biconnectivity

const LBC = LightGraphs.Biconnectivity

const conntestdir = dirname(@__FILE__)

const conntests = [
    "articulation.jl",
    "biconnect.jl",
    "bridge.jl"
]

@testset "LightGraphs.Biconnectivity" begin
    for t in conntests
        tp = joinpath(conntestdir, "$t")
        include(tp)
    end
end