using LightGraphs
using LightGraphs.SimpleGraphs
using Base.Test

const testdir = dirname(@__FILE__)

testgraphs(g) = [g, Graph{UInt8}(g), Graph{Int16}(g)]
testdigraphs(g) = [g, DiGraph{UInt8}(g), DiGraph{Int16}(g)]

# some operations will create a large graph from two smaller graphs. We
# might error out on very small eltypes.
testlargegraphs(g) = [g, Graph{UInt16}(g), Graph{Int32}(g)]
testlargedigraphs(g) = [g, DiGraph{UInt16}(g), DiGraph{Int32}(g)]

tests = [
    "graphtypes/simplegraphs/runtests",
    "linalg/runtests",
    "interface",
    "core",
    "operators",
    # "graphdigraph",
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
    "shortestpaths/floyd-warshall",
    "shortestpaths/yen",
    "traversals/bfs",
    "traversals/parallel_bfs",
    "traversals/bipartition",
    "traversals/dfs",
    "traversals/maxadjvisit",
    "traversals/randomwalks",
    "traversals/diffusion",
    "community/cliques",
    "community/core-periphery",
    "community/label_propagation",
    "community/modularity",
    "community/clustering",
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/degree",
    "centrality/katz",
    "centrality/pagerank",
    "centrality/eigenvector",
    "centrality/stress",
    "centrality/radiality",
    "flow/edmonds_karp",
    "flow/dinic",
    "flow/boykov_kolmogorov",
    "flow/push_relabel",
    "flow/maximum_flow",
    "flow/multiroute_flow",
    "utils",
    "spanningtrees/kruskal",
    "spanningtrees/prim",
    "biconnectivity/articulation",
    "biconnectivity/biconnect"
]

@testset "LightGraphs" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
