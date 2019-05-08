@test_approx_eq_eps(pagerank(g5)[3], 0.318, 0.001)
@test_throws ErrorException pagerank(g5, 2)
@test_throws ErrorException pagerank(g5, 0.85, 2)
