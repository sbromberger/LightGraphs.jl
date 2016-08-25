include("../src/LightGraphs.jl")
using LightGraphs
using Base.Test


function _make_simple_undirected_graph{T<:Integer}(n::T, edgelist::Vector{Tuple{T,T}})
    g = Graph(n)
    for (s,d) in edgelist
        add_edge!(g, Edge(s,d))
    end
    return g
end

BullGraph() =
    _make_simple_undirected_graph(5, [(1,2), (1,3), (2,3), (2,4), (3,5)])

function PetersenGraph()
    e = [
        (1, 2), (1, 5), (1, 6),
        (2, 3), (2, 7),
        (3, 4), (3, 8),
        (4, 5), (4, 9),
        (5, 10),
        (6, 8), (6, 9),
        (7, 9), (7, 10),
        (8, 10)
    ]
    return _make_simple_undirected_graph(10,e)
end

function TutteGraph()
    e = [
    (1, 2),(1, 3),(1, 4),
    (2, 5),(2, 27),
    (3, 11),(3, 12),
    (4, 19),(4, 20),
    (5, 6),(5, 34),
    (6, 7),(6, 30),
    (7, 8),(7, 28),
    (8, 9),(8, 15),
    (9, 10),(9, 39),
    (10, 11),(10, 38),
    (11, 40),
    (12, 13),(12, 40),
    (13, 14),(13, 36),
    (14, 15),(14, 16),
    (15, 35),
    (16, 17),(16, 23),
    (17, 18),(17, 45),
    (18, 19),(18, 44),
    (19, 46),
    (20, 21),(20, 46),
    (21, 22),(21, 42),
    (22, 23),(22, 24),
    (23, 41),
    (24, 25),(24, 28),
    (25, 26),(25, 33),
    (26, 27),(26, 32),
    (27, 34),
    (28, 29),
    (29, 30),(29, 33),
    (30, 31),
    (31, 32),(31, 34),
    (32, 33),
    (35, 36),(35, 39),
    (36, 37),
    (37, 38),(37, 40),
    (38, 39),
    (41, 42),(41, 45),
    (42, 43),
    (43, 44),(43, 46),
    (44, 45)
    ]
    return _make_simple_undirected_graph(46,e)
end

function HouseGraph()
    e = [ (1, 2), (1, 3), (2, 4), (3, 4), (3, 5), (4, 5) ]
    return _make_simple_undirected_graph(5,e)
end


g1 = PetersenGraph()
g2 = TutteGraph()
g3 = PathGraph(5)
g4 = PathDiGraph(5)
g5 = DiGraph(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)

h1 = Graph(5)
h2 = Graph(3)
h3 = Graph()
h4 = DiGraph(7)
h5 = DiGraph()

# self loops
s2 = DiGraph(3)
add_edge!(s2,1,2); add_edge!(s2,2,3); add_edge!(s2,3,3)
s1 = Graph(s2)

r1 = Graph(10,20)
r2 = DiGraph(5,10)

e0 = Edge(2, 3)
e1 = Edge(1, 2)
re1 = Edge(2, 1)

testdir = dirname(@__FILE__)

pdict = load(joinpath(testdir,"testdata","tutte-pathdigraph.jgz"))
p1 = pdict["Tutte"]
p2 = pdict["pathdigraph"]


adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]

a1 = Graph(adjmx1)
a2 = DiGraph(adjmx2)

tests = [
    "core",
    "edgeiter",
    "operators",
    "graphdigraph",
    "persistence",
    "distance",
    "spectral",
    "cliques",
    "subgraphs",
    "connectivity",
    "randgraphs",
    "generators",
    "shortestpaths/astar",
    "shortestpaths/bellman-ford",
    "shortestpaths/dijkstra",
    "shortestpaths/floyd-warshall",
    "traversals/bfs",
    "traversals/dfs",
    "traversals/maxadjvisit",
    "traversals/graphvisit",
    "traversals/randomwalks",
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
    "utils"
]


for t in tests
    tp = joinpath(testdir,"$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
