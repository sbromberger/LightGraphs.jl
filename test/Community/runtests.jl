using LightGraphs.Community

const communitytestdir = dirname(@__FILE__)

communitytests = [
    "clique_percolation.jl"
    "cliques.jl"
    "clustering.jl"
    "core-periphery.jl"
    "label_propagation.jl"
    "modularity.jl"
]

@testset "LightGraphs.Community" begin
    for t in communitytests
        tp = joinpath(communitytestdir, "$t")
        include(tp)
    end
end

