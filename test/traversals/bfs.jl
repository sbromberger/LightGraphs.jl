z = bfs_tree(g5, 1)
visitor = LightGraphs.TreeBFSVisitorVector(zeros(Int,nv(g5)))
t = LightGraphs.bfs_tree(visitor, g5, 1)
@test nv(z) == 4 && ne(z) == 3 && !has_edge(z, 2, 3)
@test t == [1,1,1,3]

g = HouseGraph()
@test gdistances(g, 2) == [1, 0, 2, 1, 2]
@test gdistances(g, [1,2]) == [0, 0, 1, 1, 2]
@test !is_bipartite(g)

g = Graph(5)
add_edge!(g,1,2); add_edge!(g,1,4)
add_edge!(g,2,3); add_edge!(g,2,5)
add_edge!(g,3,4)
@test is_bipartite(g)
