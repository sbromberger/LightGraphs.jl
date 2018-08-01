using LightGraphs
using LightGraphs.Parallel

@test length(description()) > 1

tests = [
    "centrality/betweenness",
]

@testset "LightGraphs.Parallel" begin
    for t in tests
        tp = joinpath(testdir, "parallel", "$(t).jl")
        include(tp)
    end
end
