suite["centrality"] = BenchmarkGroup(["degree", "closeness", "betweenness", "katz", "pagerank"])

# betweenness
suite["centrality"]["degree"] = BenchmarkGroup(["graphs", "digraphs"])
suite["centrality"]["degree"]["graphs"] = @benchmarkable [LightGraphs.degree_centrality(g) for (n,g) in $GRAPHS]
suite["centrality"]["degree"]["digraphs"] = @benchmarkable [LightGraphs.degree_centrality(g) for (n,g) in $DIGRAPHS]

# closeness
suite["centrality"]["closeness"] = BenchmarkGroup(["graphs", "digraphs"])
suite["centrality"]["closeness"]["graphs"] = @benchmarkable [LightGraphs.closeness_centrality(g) for (n,g) in $GRAPHS]
suite["centrality"]["closeness"]["digraphs"] = @benchmarkable [LightGraphs.closeness_centrality(g) for (n,g) in $DIGRAPHS]

# betweenness
suite["centrality"]["betweenness"] = BenchmarkGroup(["graphs", "digraphs"])
suite["centrality"]["betweenness"]["graphs"] = @benchmarkable [LightGraphs.betweenness_centrality(g) for (n,g) in $GRAPHS if nv(g) < 1000]
suite["centrality"]["betweenness"]["digraphs"] = @benchmarkable [LightGraphs.betweenness_centrality(g) for (n,g) in $DIGRAPHS if nv(g) < 1000]

# katz
suite["centrality"]["katz"] = BenchmarkGroup(["graphs", "digraphs"])
suite["centrality"]["katz"]["graphs"] = @benchmarkable [LightGraphs.katz_centrality(g) for (n,g) in $GRAPHS if nv(g) < 1000]
suite["centrality"]["katz"]["digraphs"] = @benchmarkable [LightGraphs.katz_centrality(g) for (n,g) in $DIGRAPHS if nv(g) < 1000]

#pagerank
suite["centrality"]["katz"] = BenchmarkGroup(["digraphs"])
suite["centrality"]["katz"]["digraphs"] = @benchmarkable [LightGraphs.pagerank(g) for (n,g) in $DIGRAPHS if nv(g) < 500]
