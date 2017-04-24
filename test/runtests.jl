using LightGraphs
using LightGraphs.SimpleGraphs
using LightGraphs.LinAlg
using Base.Test

# g1 = smallgraph(:petersen)
# g2 = smallgraph(:tutte)
# g3 = PathGraph(5)
# g4 = PathDiGraph(5)
# g5 = DiGraph(4)
# add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
# g6 = smallgraph(:house)
#
# h1 = Graph(5)
# h2 = Graph(3)
# h3 = Graph()
# h4 = DiGraph(7)
# h5 = DiGraph()
#
# # self loops
# s2 = DiGraph(3)
# add_edge!(s2,1,2); add_edge!(s2,2,3); add_edge!(s2,3,3)
# s1 = Graph(s2)
#
# r1 = Graph(10,20)
# r2 = DiGraph(5,10)
#
# e0 = Edge(2, 3)
# e1 = Edge(1, 2)
# re1 = Edge(2, 1)
#
# # polygons
# triangle = random_regular_graph(3,2)
# quadrangle = random_regular_graph(4,2)
# pentagon = random_regular_graph(5,2)

testdir = dirname(@__FILE__)

testgraphs(g) = [g, Graph{UInt8}(g), Graph{Int16}(g)]
testdigraphs(g) = [g, DiGraph{UInt8}(g), DiGraph{Int16}(g)]

# some operations will create a large graph from two smaller graphs. We
# might error out on very small eltypes.
testlargegraphs(g) = [g, Graph{UInt16}(g), Graph{Int32}(g)]
testlargedigraphs(g) = [g, DiGraph{UInt16}(g), DiGraph{Int32}(g)]

tests = [
    "interface",
    "core",
    "graphtypes/simplegraphs/simplegraphs",
    "graphtypes/simplegraphs/simpleedge",
    "graphtypes/simplegraphs/simpleedgeiter",
    "operators",
    # "graphdigraph",
    "distance",
    "edit_distance",
    "linalg/spectral",
    "linalg/graphmatrices",
    "connectivity",
    "transitivity",
    "persistence/persistence",
    "generators/randgraphs",
    "generators/staticgraphs",
    "generators/smallgraphs",
    "generators/euclideangraphs",
    "shortestpaths/astar",
    "shortestpaths/bellman-ford",
    "shortestpaths/dijkstra",
    "shortestpaths/floyd-warshall",
    "traversals/bfs",
    "traversals/dfs",
    "traversals/maxadjvisit",
    "traversals/graphvisit",
    "traversals/randomwalks",
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

@testset begin
    for t in tests
        tp = joinpath(testdir,"$(t).jl")
        include(tp)
    end
end
