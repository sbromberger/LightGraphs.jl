suite["centrality"] = BenchmarkGroup(["graphs", "digraphs"])
suite["centrality"]["graphs"] = @benchmarkable [LightGraphs.connected_components(g) for (n,g) in $GRAPHS]
suite["centrality"]["digraphs"] = @benchmarkable [LightGraphs.strongly_connected_components(g) for (n,g) in $DIGRAPHS]
