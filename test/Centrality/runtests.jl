using LightGraphs.Centrality

const centralitydir = dirname(@__FILE__)

centralitytests = [
    "betweenness.jl"
    "closeness.jl"
    "degree.jl"
    "eigenvector.jl"
    "katz.jl"
    "pagerank.jl"
    "radiality.jl"
    "stress.jl"
]

@testset "LightGraphs.Centrality" begin
    for t in centralitytests
        tp = joinpath(centralitydir, "$t")
        include(tp)
    end
end

