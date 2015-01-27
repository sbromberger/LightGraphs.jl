@test e1.src == src(e1) == 1
@test e1.dst == dst(e1) == 2

g = SimpleGraph(5)
add_edge!(g, 1, 2)
e2 = add_edge!(g, 1, 3)
e3 = add_edge!(g, 1, 4)
e4 = add_edge!(g, 2, 5)
e5 = add_edge!(g, 3, 5)

h = SimpleDiGraph(5)
add_edge!(h, 1, 2)
add_edge!(h, 1, 3)
add_edge!(h, 1, 4)
add_edge!(h, 2, 5)
add_edge!(h, 3, 5)


@test SimpleGraphs.rev(e1) == re1

@test sprint(show, e1) == "edge 1 - 2"
@test vertices(g) == 1:5
@test edges(g) == Set([e1, e2, e3, e4, e5])

@test p1 == g2
@test issubset(h2, h1)
@test add_vertex!(g) == 6
@test add_vertices!(g,5) == 11
@test has_edge(g, 1, 2)
@test in_edges(g, 2) == [e1, rev(e4)]
@test out_edges(g, 1) == [e1, e2, e3]
@test has_vertex(g, 11)
@test nv(g) == 11
@test ne(g) == 5
@test !is_directed(g)
@test is_directed(h)
@test degree(g, [1, 2]) == [3, 2]
@test indegree(g, [1, 2]) == [3, 2]
@test outdegree(g, [1, 2]) == [3, 2]
@test degree(h, [1, 2]) == [3, 2]
@test indegree(h, [1, 2]) == [0, 1]
@test outdegree(h, [1, 2]) == [3, 1]


@test δ(g) == 0
@test Δ(g) == 3
@test degree_histogram(g)[1:4] == [1, 3, 1, 0]
@test neighbors(g, 1) == [2, 3, 4]
@test common_neighbors(g, 2, 3) == [1, 5]
@test common_neighbors(h, 2, 3) == [5]
