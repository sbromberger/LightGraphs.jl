bg = BenchmarkGroup()
SUITE["traversals"] = bg

for (name, g) in GRAPHS
    bg["traversals","bfs_tree","graph","$name"] = @benchmarkable LightGraphs.bfs_tree($g, 1)
    bg["traversals","dfs_tree","graph","$name"] = @benchmarkable LightGraphs.dfs_tree($g, 1)
end

for (name, g) in DIGRAPHS
    bg["traversals","bfs_tree","digraph","$name"] = @benchmarkable LightGraphs.bfs_tree($g, 1)
    bg["traversals","dfs_tree","digraph","$name"] = @benchmarkable LightGraphs.dfs_tree($g, 1)
end
