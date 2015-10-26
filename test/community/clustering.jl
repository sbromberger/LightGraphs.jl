g10 = CompleteGraph(10)
@test local_clustering(g) == ones(10)
@test global_clustering(g) == 1
