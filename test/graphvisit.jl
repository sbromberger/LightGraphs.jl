# stub tests for coverage; disregards output.

f = IOBuffer()

g = HouseGraph()
@test traverse_graph_withlog(g, BreadthFirst(), [1;], f) == nothing
