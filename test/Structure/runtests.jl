using Random: MersenneTwister, randperm
using LightGraphs, LightGraphs.SimpleGraphs, LightGraphs.Generators, LightGraphs.Structure
const structuretestdir = dirname(@__FILE__)
const SG = LightGraphs.SimpleGraphs
const LGGEN = LightGraphs.Generators
const LGST = LightGraphs.Structure
tests = [
        "edit_distance",
         "isomorphism",
        ]

@testset "Structure" begin
    for t in tests
        tp = joinpath(structuretestdir, "$(t).jl")
        include(tp)
    end
end
