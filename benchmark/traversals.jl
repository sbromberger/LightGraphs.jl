@benchgroup "traversals" begin
    @benchgroup "graphs" begin
        for (name, g) in GRAPHS
            @bench "$(name): bfs_tree" LightGraphs.bfs_tree($g, 1)
            @bench "$(name): dfs_tree" LightGraphs.dfs_tree($g, 1)
        end
    end # graphs
    @benchgroup "digraphs" begin
        for (name, g) in DIGRAPHS
            @bench "$(name): bfs_tree" LightGraphs.bfs_tree($g, 1)
            @bench "$(name): dfs_tree" LightGraphs.dfs_tree($g, 1)
        end
    end # digraphs
end # traversals
