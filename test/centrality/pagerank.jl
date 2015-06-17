@test round(pagerank(g5)[3],3) == 0.318
@test_throws ErrorException pagerank(g5, 2)
@test_throws ErrorException pagerank(g5, 0.85, 2)
