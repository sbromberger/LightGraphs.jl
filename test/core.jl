@test e1.src == src(e1) == 1
@test e1.dst == dst(e1) == 2

g = Graph(5)
add_edge!(g, 1, 2)
e2 = add_edge!(g, 1, 3)
e3 = add_edge!(g, 1, 4)
e4 = add_edge!(g, 2, 5)
e5 = add_edge!(g, 3, 5)

h = DiGraph(5)
add_edge!(h, 1, 2)
add_edge!(h, 1, 3)
add_edge!(h, 1, 4)
add_edge!(h, 2, 5)
add_edge!(h, 3, 5)

@test rev(e1) == re1

@test sprint(show, e1) == "edge 1 - 2"
@test vertices(g) == 1:5
@test edges(g) == Set([e1, e2, e3, e4, e5])

@test degree(g) == [3, 2, 2, 1, 2]
@test indegree(g) == [3, 2, 2, 1, 2]
@test indegree(g,1) == 3
@test outdegree(g) == [3, 2, 2, 1, 2]
@test outdegree(g,1) == 3
@test degree(h) == [3, 2, 2, 1, 2]
@test indegree(h) == [0, 1, 1, 1, 2]
@test indegree(h,1) == 0
@test outdegree(h) == [3, 1, 1, 0, 0]
@test outdegree(h,1) == 3
@test in_neighbors(h,5) == [2, 3]
@test out_neighbors(h,1) == [2, 3, 4]

@test p1 == g2
@test issubset(h2, h1)

@test has_edge(g, 1, 2)
@test in_edges(g, 2) == [e1, rev(e4)]
@test out_edges(g, 1) == [e1, e2, e3]

@test add_vertex!(g) == 6
@test add_vertices!(g,5) == 11
@test has_vertex(g, 11)
@test nv(g) == 11
@test ne(g) == 5
@test !is_directed(g)
@test is_directed(h)

@test δ(g) == 0
@test Δ(g) == 3
@test degree_histogram(g)[1:4] == [1, 3, 1, 0]
@test neighbors(g, 1) == [2, 3, 4]
@test common_neighbors(g, 2, 3) == [1, 5]
@test common_neighbors(h, 2, 3) == [5]

@test rem_edge!(g, 1, 2) == e1
@test_throws ErrorException rem_edge!(g, 2, 1)
add_edge!(g, 1, 2)
@test rem_edge!(g, 2, 1) == e1

@test rem_edge!(h, 1, 2) == e1
@test_throws ErrorException rem_edge!(h, 1, 2)
