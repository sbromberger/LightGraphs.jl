using LightGraphs
using LightGraphs.SimpleGraphs
using Test
using SparseArrays
using LinearAlgebra
using DelimitedFiles
using Base64

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
    "digraph/cycles/hadwick-james",
    "digraph/cycles/johnson",
    "digraph/cycles/karp",
    "edit_distance",
    "connectivity",
    "persistence/persistence",
    "generators/randgraphs",
    "generators/staticgraphs",
    "generators/smallgraphs",
    "generators/euclideangraphs",
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
    "traversals/metric_travelling_salesman",
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
    "steinertree/steiner_tree",
    "steinertree/metric_steiner_tree",
    "biconnectivity/articulation",
    "biconnectivity/pairwise_connectivity",
    "biconnectivity/biconnect",
    "graphcut/normalized_cut"
]

@testset "LightGraphs" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
