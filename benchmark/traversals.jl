suite["traversals"] = BenchmarkGroup(["bfs", "dfs"])

# breadth first
suite["traversals"]["bfs"] = BenchmarkGroup(["graphs", "digraphs"])
suite["traversals"]["bfs"]["graphs"] = @benchmarkable [LightGraphs.bfs_tree(g, 1) for (n,g) in $GRAPHS]
suite["traversals"]["bfs"]["digraphs"] = @benchmarkable [LightGraphs.bfs_tree(g, 1) for (n,g) in $DIGRAPHS]

# depth first
suite["traversals"]["dfs"] = BenchmarkGroup(["graphs", "digraphs"])
suite["traversals"]["dfs"]["graphs"] = @benchmarkable [LightGraphs.dfs_tree(g, 1) for (n,g) in $GRAPHS]
suite["traversals"]["dfs"]["digraphs"] = @benchmarkable [LightGraphs.dfs_tree(g, 1) for (n,g) in $DIGRAPHS]
