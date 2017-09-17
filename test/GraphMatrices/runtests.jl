using LightGraphs.GraphMatrices

const linalgtestdir = dirname(@__FILE__)

tests = [
    "graphmatrix",
    "nonbacktracking"
]


@testset "LightGraphs.GraphMatrices" begin
    for t in tests
        tp = joinpath(linalgtestdir, "$(t).jl")
        include(tp)
    end
end