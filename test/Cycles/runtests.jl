using LightGraphs.Cycles

const cycletestdir = dirname(@__FILE__)

cycletests = [
    "basis.jl"
    "hawick-james.jl"
    "johnson.jl"
    "karp.jl"
    "limited_length.jl"
]

@testset "LightGraphs.Cycles" begin
    for t in cycletests
        tp = joinpath(cycletestdir, "$t")
        include(tp)
    end
end

