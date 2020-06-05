using LightGraphs
using LightGraphs.SimpleGraphs
using LightGraphs.SimpleGraphs: SimpleDiGraph, SimpleGraph, AbstractSimpleGraph, AbstractSimpleEdge
using LightGraphs.SimpleGraphs.Generators
using LightGraphs.Experimental
using Test
using SparseArrays
using LinearAlgebra
using DelimitedFiles
using Base64
using Random
using Statistics: mean

const SG = LightGraphs.SimpleGraphs
const SGGEN = LightGraphs.SimpleGraphs.Generators

const testdir = dirname(@__FILE__)

testgraphs(g) = is_directed(g) ? [g, SimpleDiGraph{UInt8}(g), SimpleDiGraph{Int16}(g)] : [g, SimpleGraph{UInt8}(g), SimpleGraph{Int16}(g)]
testgraphs(gs...) = vcat((testgraphs(g) for g in gs)...)
testdigraphs = testgraphs

# some operations will create a large graph from two smaller graphs. We
# might error out on very small eltypes.
testlargegraphs(g) = is_directed(g) ? [g, SimpleDiGraph{UInt16}(g), SimpleDiGraph{Int32}(g)] : [g, SimpleGraph{UInt16}(g), SimpleGraph{Int32}(g)]
testlargegraphs(gs...) = vcat((testlargegraphs(g) for g in gs)...)

# make sure we don't have any unbound type parameters
# see https://discourse.julialang.org/t/unused-where-t-causes-a-function-to-become-very-slow/39727
@test isempty(detect_unbound_args(LightGraphs))

tests = [
    "SimpleGraphsCore/runtests",
    "SimpleGraphs/runtests",
    "linalg13/runtests",
    "parallel13/runtests",
    "interface",
    "contiguous_vertices",
    "core",
    "operators",
    "Degeneracy/runtests",
    "defaultdistance",
    "Measurements/runtests",
    "Transitivity/runtests",
    "Cycles/runtests",
    "Connectivity/runtests",
    "persistence13/persistence",
    "ShortestPaths/runtests",
    "Traversals/runtests",
    "Coloring/runtests",
    "Community/runtests",
    "Centrality/runtests",
    "Structure/runtests",
    "utils",
    "steinertree13/steiner_tree",
    "biconnectivity13/articulation",
    "biconnectivity13/biconnect",
    "biconnectivity13/bridge",
    "graphcut13/normalized_cut",
    "graphcut13/karger_min_cut",
    "spanningtrees13/boruvka",
    "spanningtrees13/kruskal",
    "spanningtrees13/prim",
    "VertexSubsets/runtests",
    "deprecations13/experimental/experimental",
    "deprecations13/digraph13/transitivity",
    "deprecations13/cycles13/hawick-james",
    "deprecations13/cycles13/johnson",
    "deprecations13/cycles13/karp",
    "deprecations13/cycles13/basis",
    "deprecations13/cycles13/limited_length",
    "deprecations13/degeneracy13",
    "deprecations13/distance13",
    "deprecations13/connectivity13",
    "deprecations13/shortestpaths13/astar",
    "deprecations13/shortestpaths13/bellman-ford",
    "deprecations13/shortestpaths13/desopo-pape",
    "deprecations13/shortestpaths13/dijkstra",
    "deprecations13/shortestpaths13/johnson",
    "deprecations13/shortestpaths13/floyd-warshall",
    "deprecations13/shortestpaths13/yen",
    "deprecations13/shortestpaths13/spfa",
    "deprecations13/traversals13/bfs",
    "deprecations13/traversals13/bipartition",
    "deprecations13/traversals13/greedy_color",
    "deprecations13/traversals13/dfs",
    "deprecations13/traversals13/maxadjvisit",
    "deprecations13/traversals13/randomwalks",
    "deprecations13/traversals13/diffusion",
    "deprecations13/community13/cliques",
    "deprecations13/community13/core-periphery",
    "deprecations13/community13/label_propagation",
    "deprecations13/community13/modularity",
    "deprecations13/community13/clustering",
    "deprecations13/community13/clique_percolation",
    "deprecations13/centrality13/betweenness",
    "deprecations13/centrality13/closeness",
    "deprecations13/centrality13/degree",
    "deprecations13/centrality13/katz",
    "deprecations13/centrality13/pagerank",
    "deprecations13/centrality13/eigenvector",
    "deprecations13/centrality13/stress",
    "deprecations13/centrality13/radiality",
    "deprecations13/dominatingset13/degree_dom_set",
    "deprecations13/dominatingset13/minimal_dom_set",
    "deprecations13/independentset13/degree_ind_set",
    "deprecations13/independentset13/maximal_ind_set",
    "deprecations13/vertexcover13/degree_vertex_cover",
    "deprecations13/vertexcover13/random_vertex_cover",
    "edit_distance",  # deprecations
]

@testset "LightGraphs" begin
    for t in tests
        @info "Testing $t"
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
