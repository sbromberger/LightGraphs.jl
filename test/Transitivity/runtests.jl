using LightGraphs.Transitivity

const transtestdir = dirname(@__FILE__)

transtests = [
    "transitivity.jl"
]

@testset "LightGraphs.Transitivity" begin
    for t in transtests
        println("transitivity: testing $t")
        tp = joinpath(transtestdir, "$t")
        include(tp)
    end
end

