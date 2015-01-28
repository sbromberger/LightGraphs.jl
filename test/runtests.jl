using Compat  # for readcentrality() in test/centrality/betweenness.jl
using LightGraphs
using Base.Test

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

r1 = Graph(10,20)
r2 = DiGraph(5,10)

e0 = Edge(2, 3)
e1 = Edge(1, 2)
re1 = Edge(2, 1)

testdir = joinpath(Pkg.dir("LightGraphs"),"test")

p1 = readgraph(joinpath(testdir,"testdata","tutte.jgz"))
p2 = readgraph(joinpath(testdir,"testdata","pathdigraph.jgz"))

adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph

a1 = Graph(adjmx1)
a2 = DiGraph(adjmx2)

tests = [
    "graphdigraph",
    "persistence",
    "core",
    "smallgraphs",
    "astar",
    "bellman-ford",
    "dijkstra",
    "distance",
    "floyd-warshall",
    "linalg",
    "operators",
    "randgraphs",
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/degree"
    ]


for t in tests
    tp = joinpath(testdir,"$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
