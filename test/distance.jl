@test_throws ErrorException LightGraphs._all_eccentricities(g4)
z = LightGraphs._all_eccentricities(g3)
@test z == [4, 3, 2, 3, 4]
@test diameter(z) == diameter(g3) == 4.0
@test periphery(z) == periphery(g3) == [1,5]
@test radius(z) == radius(g3) == 2.0
@test center(z) == center(g3) == [3]
