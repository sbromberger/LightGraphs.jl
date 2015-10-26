g10 = CompleteGraph(10)
@test local_clustering(g10) == ones(10)
@test global_clustering(g10) == 1
