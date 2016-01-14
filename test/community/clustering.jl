g10 = CompleteGraph(10)
@test local_clustering_coefficient(g10) == ones(10)
@test global_clustering_coefficient(g10) == 1
@test local_clustering(g10) == (fill(36, 10), fill(36, 10))
