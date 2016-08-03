# stub tests for coverage; disregards output.

f = IOBuffer()

g = HouseGraph()
@test traverse_graph_withlog(g, BreadthFirst(), [1;], f) == nothing

@test visited_vertices(g, BreadthFirst(), [1;]) == [1, 2, 3, 4, 5]


function trivialgraphvisit(
    g::SimpleGraph,
    alg::LightGraphs.SimpleGraphVisitAlgorithm,
    sources
)
    visitor = TrivialGraphVisitor()
    traverse_graph!(g, alg, sources, visitor)
end

@test trivialgraphvisit(g, BreadthFirst(), 1) == nothing

# this just exercises some graph visitors
@test traverse_graph!(g, BreadthFirst(), 1, TrivialGraphVisitor()) == nothing
@test traverse_graph!(g, BreadthFirst(), 1, LogGraphVisitor(IOBuffer())) == nothing

# dummy edge map test
d = LightGraphs.DummyEdgeMap()
e = Edge(1,2)
@test d[e] == 0
