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
    traverse_graph(g, alg, sources, visitor)
end

@test trivialgraphvisit(g, BreadthFirst(), 1) == nothing
