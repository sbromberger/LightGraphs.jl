@test sprint(show, h1) == "{5, 0} undirected graph"
@test sprint(show, h3) == "empty undirected graph"

@test Graph(DiGraph(g3)) == g3

@test degree(g3, 1) == 1
# @test all_neighbors(g3, 3) == [2, 4]
@test density(g3) == 0.4

g = Graph(5)
@test add_edge!(g, 1, 2) == e1
e2 = add_edge!(g, 1, 3)
e3 = add_edge!(g, 1, 4)
e4 = add_edge!(g, 2, 5)
e5 = add_edge!(g, 3, 5)

h = DiGraph(5)
@test add_edge!(h, 1, 2) == e1
add_edge!(h, 1, 3)
add_edge!(h, 1, 4)
add_edge!(h, 2, 5)
add_edge!(h, 3, 5)

@test LightGraphs.fadj(g)[1] == LightGraphs.fadj(g,1) ==
    LightGraphs.badj(g)[1] == LightGraphs.badj(g,1) ==
    LightGraphs.adj(g)[1] == LightGraphs.adj(g,1) ==
    [2,3,4]

# @test_throws ErrorException add_edge!(g, 1, 2)
# @test_throws ErrorException add_edge!(h, 1, 2)
# @test_throws ErrorException add_edge!(g, 1, 1)
# @test_throws ErrorException add_edge!(h, 1, 1)

@test sprint(show, h4) == "{7, 0} directed graph"
@test sprint(show, h5) == "empty directed graph"
@test has_edge(g, e1)
@test has_edge(h, e1)
@test !has_edge(g, e0)
@test !has_edge(h, e0)

@test degree(g4, 1) == 1
# @test all_neighbors(g4, 3) == [4]
@test density(g4) == 0.2

@test nv(a1) == 3
@test ne(a1) == 2
@test nv(a2) == 3
@test ne(a2) == 5

badadjmx = [ 0 1 0; 1 0 1]
@test_throws ErrorException Graph(badadjmx)
@test_throws ErrorException Graph(sparse(badadjmx))
@test_throws ErrorException DiGraph(badadjmx)
@test_throws ErrorException DiGraph(sparse(badadjmx))
@test_throws ErrorException Graph([1 0; 1 1])


@test_throws ErrorException add_edge!(g, 100, 100)
@test_throws ErrorException add_edge!(h, 100, 100)

@test_throws ErrorException Graph(sparse(adjmx2))

g = Graph(sparse(adjmx1))
h = DiGraph(sparse(adjmx1))

@test (nv(g), ne(g)) == (3, 2)
@test (nv(h), ne(h)) == (3, 4)
@test Graph(h) == g

@test sort(all_neighbors(WheelDiGraph(10),2)) == [1, 3, 10]
