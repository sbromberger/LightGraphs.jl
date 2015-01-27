using Compat  # for readcentrality() in test/centrality/betweenness.jl
using SimpleGraphs
using Base.Test

g1 = PetersenGraph()
g2 = TutteGraph()
g3 = PathGraph(5)
g4 = PathDiGraph(5)
g5 = SimpleDiGraph(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)

h1 = SimpleGraph(5)
h2 = SimpleGraph(3)
h3 = SimpleGraph()
h4 = SimpleDiGraph(7)
h5 = SimpleDiGraph()

r1 = SimpleGraph(10,20)
r2 = SimpleDiGraph(5,10)

e0 = Edge(2, 3)
e1 = Edge(1, 2)
re1 = Edge(2, 1)

testdir = joinpath(Pkg.dir("SimpleGraphs"),"test")

p1 = readsimplegraph(joinpath(testdir,"testdata","tutte.jgz"))
p2 = readsimplegraph(joinpath(testdir,"testdata","pathdigraph.jgz"))

adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph

a1 = SimpleGraph(adjmx1)
a2 = SimpleDiGraph(adjmx2)

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
