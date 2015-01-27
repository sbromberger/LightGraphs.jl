@test sprint(show, h1) == "{5, 0} undirected graph"
@test sprint(show, h3) == "empty undirected graph"

@test FastGraph(g4) == g3

@test degree(g3, 1) == 1
@test all_neighbors(g3, 3) == [2, 4]
@test density(g3) == 0.4

g = FastGraph(5)
@test add_edge!(g, 1, 2) == e1
e2 = add_edge!(g, 1, 3)
e3 = add_edge!(g, 1, 4)
e4 = add_edge!(g, 2, 5)
e5 = add_edge!(g, 3, 5)

h = FastDiGraph(5)
@test add_edge!(h, 1, 2) == e1
add_edge!(h, 1, 3)
add_edge!(h, 1, 4)
add_edge!(h, 2, 5)
add_edge!(h, 3, 5)

@test_throws ErrorException add_edge!(g, 1, 2)
@test_throws ErrorException add_edge!(h, 1, 2)

@test sprint(show, h4) == "{7, 0} directed graph"
@test sprint(show, h5) == "empty directed graph"
@test has_edge(g, e1)
@test has_edge(h, e1)
@test !has_edge(g, e0)
@test !has_edge(h, e0)
