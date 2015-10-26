g = PathDiGraph(10)
@test randomwalk(g, 1, 5) == [1:5;]
@test randomwalk(g, 2, 100) == [2:10;]
@test_throws BoundsError randomwalk(g, 20, 20)

g = PathGraph(10)
@test saw(g, 1, 20) == [1:10;]
@test_throws BoundsError saw(g, 20, 20)

g = PathGraph(10)
@test non_backtracking_randomwalk(g, 1, 20) == [1:10;]
@test_throws BoundsError non_backtracking_randomwalk(g, 20, 20)
