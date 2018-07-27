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

testgraphs(g) = [g, Graph{UInt8}(g), Graph{Int16}(g)]
testdigraphs(g) = [g, DiGraph{UInt8}(g), DiGraph{Int16}(g)]

# some operations will create a large graph from two smaller graphs. We
# might error out on very small eltypes.
testlargegraphs(g) = [g, Graph{UInt16}(g), Graph{Int32}(g)]
testlargedigraphs(g) = [g, DiGraph{UInt16}(g), DiGraph{Int32}(g)]

tests = [
    "simplegraphs/runtests",
    "linalg/runtests",
    "interface",
    "core",
    "operators",
    "degeneracy",
    "distance",
    "digraph/transitivity",
    "cycles/hadwick-james",
    "cycles/johnson",
    "cycles/karp",
    "cycles/basis",
    "edit_distance",
    "connectivity",
    "persistence/persistence",
    "shortestpaths/astar",
    "shortestpaths/bellman-ford",
    "shortestpaths/dijkstra",
    "shortestpaths/johnson",
    "shortestpaths/floyd-warshall",
    "shortestpaths/yen",
    "traversals/bfs",
    "traversals/parallel_bfs",
    "traversals/bipartition",
    "traversals/greedy_color",
    "traversals/dfs",
    "traversals/maxadjvisit",
    "traversals/randomwalks",
    "traversals/diffusion",
    "community/cliques",
    "community/core-periphery",
    "community/label_propagation",
    "community/modularity",
    "community/clustering",
    "community/clique_percolation",
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/degree",
    "centrality/katz",
    "centrality/pagerank",
    "centrality/eigenvector",
    "centrality/stress",
    "centrality/radiality",
    "utils",
    "spanningtrees/kruskal",
    "spanningtrees/prim",
    "biconnectivity/articulation",
    "biconnectivity/biconnect",
    "graphcut/normalized_cut",
    "experimental/experimental"
]

@testset "LightGraphs" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
