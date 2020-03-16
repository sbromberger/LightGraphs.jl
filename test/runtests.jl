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
    "simplegraphs/runtests",
    "linalg13/runtests",
    "parallel/runtests",
    "interface",
    "contiguous_vertices",
    "core",
    "operators",
    "degeneracy",
    "distance",
    "digraph13/transitivity",
    "digraph13/dominator_tree",
    "cycles13/hawick-james",
    "cycles13/johnson",
    "cycles13/karp",
    "cycles13/basis",
    "cycles13/limited_length",
    "edit_distance",
    "connectivity",
    "persistence13/persistence",
    "shortestpaths13/astar",
    "shortestpaths13/bellman-ford",
    "shortestpaths13/desopo-pape",
    "shortestpaths13/dijkstra",
    "shortestpaths13/johnson",
    "shortestpaths13/floyd-warshall",
    "shortestpaths13/yen",
    "shortestpaths13/spfa",
    "traversals13/bfs",
    "traversals13/bipartition",
    "traversals13/greedy_color",
    "traversals13/dfs",
    "traversals13/maxadjvisit",
    "traversals13/randomwalks",
    "traversals13/diffusion",
    "Traversals/runtests",
    "community13/cliques",
    "community13/core-periphery",
    "community13/label_propagation",
    "community13/modularity",
    "community13/clustering",
    "community13/clique_percolation",
    "centrality13/betweenness",
    "centrality13/closeness",
    "centrality13/degree",
    "centrality13/katz",
    "centrality13/pagerank",
    "centrality13/eigenvector",
    "centrality13/stress",
    "centrality13/radiality",
    "utils",
    "deprecations",
    "spanningtrees13/boruvka",
    "spanningtrees13/kruskal",
    "spanningtrees13/prim",
    "steinertree13/steiner_tree",
    "biconnectivity13/articulation",
    "biconnectivity13/biconnect",
    "biconnectivity13/bridge",
    "graphcut13/normalized_cut",
    "graphcut13/karger_min_cut",
    "dominatingset13/degree_dom_set",
    "dominatingset13/minimal_dom_set",
    "independentset13/degree_ind_set",
    "independentset13/maximal_ind_set",
    "vertexcover13/degree_vertex_cover",
    "vertexcover13/random_vertex_cover",
    "experimental/experimental"
]

@testset "LightGraphs" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
