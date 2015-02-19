# Test of breadth-first-search

using LightGraphs
using Base.Test

g = DiGraph(6)

add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 1, 6)
add_edge!(g, 2, 4)
add_edge!(g, 2, 5)
add_edge!(g, 3, 5)
add_edge!(g, 3, 6)
add_edge!(g, 5, 1)

@assert nv(g) == 6
@assert ne(g) == 8

vs1 = visited_vertices(g, BreadthFirst(), 1)
ds1 = gdistances(g, 1)
@test vs1 == [1, 2, 3, 6, 4, 5]
@test ds1 == [0, 1, 1, 2, 2, 1]

vs2 = visited_vertices(g, BreadthFirst(), [1, 3])
ds2 = gdistances(g, [1, 3])
@test vs2 == [1, 3, 2, 6, 5, 4]
@test ds2 == [0, 1, 0, 2, 1, 1]
