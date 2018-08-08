using LightGraphs.LinAlg
using Arpack
using Random
using SparseArrays
using LinearAlgebra
const linalgtestdir = dirname(@__FILE__)

tests = [
    "graphmatrices",
    "spectral"
]


@testset "LightGraphs.LinAlg" begin
    for t in tests
        tp = joinpath(linalgtestdir, "$(t).jl")
        include(tp)
    end
end
