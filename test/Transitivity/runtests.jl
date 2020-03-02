using LightGraphs.Transitivity

const transtestdir = dirname(@__FILE__)

transtests = [
    "transitivity.jl"
]

@testset "LightGraphs.Transitivity" begin
    for t in transtests
        tp = joinpath(transtestdir, "$t")
        include(tp)
    end
end

