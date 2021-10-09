suite["connectivity"] = BenchmarkGroup(["graphs", "digraphs"])
suite["connectivity"]["graphs"] = @benchmarkable [LightGraphs.connected_components(g) for (n,g) in $GRAPHS]
suite["connectivity"]["digraphs"] = @benchmarkable [LightGraphs.strongly_connected_components(g) for (n,g) in $DIGRAPHS]
