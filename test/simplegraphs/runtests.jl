using LightGraphs.SimpleGraphs

import LightGraphs.SimpleGraphs: fadj, badj, adj


struct DummySimpleGraph <: AbstractSimpleGraph{Int} end

const simplegraphtestdir = dirname(@__FILE__)

tests = [
    "simplegraphs",
    "simpleedge",
    "simpleedgeiter",
    "generators/randgraphs",
    "generators/staticgraphs",
    "generators/smallgraphs",
    "generators/euclideangraphs"
]

@testset "LightGraphs.SimpleGraphs" begin
    for t in tests
        tp = joinpath(simplegraphtestdir, "$(t).jl")
        include(tp)
    end
end
