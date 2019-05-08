@test degree_centrality(g5) == [0.6666666666666666, 0.6666666666666666, 1.0, 0.3333333333333333]
@test indegree_centrality(g5, normalize=false) == [0.0, 1.0, 2.0, 1.0]
@test outdegree_centrality(g5; normalize=false) == [2.0, 1.0, 1.0, 0.0]
