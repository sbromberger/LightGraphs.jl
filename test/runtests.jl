using LightGraphs
using LightGraphs.SimpleGraphs
using LightGraphs.Experimental
using Test
using SparseArrays
using LinearAlgebra
using DelimitedFiles
using Base64
using Random
using Statistics: mean

const testdir = dirname(@__FILE__)

testgraphs(g) = is_directed(g) ? [g, DiGraph{UInt8}(g), DiGraph{Int16}(g)] : [g, Graph{UInt8}(g), Graph{Int16}(g)] 
testgraphs(gs...) = vcat((testgraphs(g) for g in gs)...)
testdigraphs = testgraphs

# some operations will create a large graph from two smaller graphs. We
# might error out on very small eltypes.
testlargegraphs(g) = is_directed(g) ? [g, DiGraph{UInt16}(g), DiGraph{Int32}(g)] : [g, Graph{UInt16}(g), Graph{Int32}(g)] 
testlargegraphs(gs...) = vcat((testlargegraphs(g) for g in gs)...)

tests = [
    "SimpleGraphs/runtests",
    "LinAlg/runtests",
    "Parallel/runtests",
    "ShortestPaths/runtests",
    "interface",
    "core",
    "operators",
    "degeneracy",
    "distance",
    "Transitivity/runtests",
    "Cycles/runtests",
    "edit_distance",
    "connectivity",
    "persistence/persistence",
    "Traversals/runtests",
    "community/cliques",
    "community/core-periphery",
    "community/label_propagation",
    "community/modularity",
    "community/clustering",
    "community/clique_percolation",
    "Centrality/runtests",
    "utils",
    "deprecations",
    "spanningtrees/boruvka",
    "spanningtrees/kruskal",
    "spanningtrees/prim",
    "steinertree/steiner_tree",
    "biconnectivity/articulation",
    "biconnectivity/biconnect",
    "biconnectivity/bridge",
    "graphcut/normalized_cut",
    "graphcut/karger_min_cut",
    "dominatingset/degree_dom_set",
    "dominatingset/minimal_dom_set",
    "independentset/degree_ind_set",
    "independentset/maximal_ind_set",
    "vertexcover/degree_vertex_cover",
    "vertexcover/random_vertex_cover",
    "Experimental/runtests"
]

@testset "LightGraphs" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
