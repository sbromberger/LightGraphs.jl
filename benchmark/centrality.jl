
@benchgroup "centrality" begin
    @benchgroup "graphs" begin
        for (name, g) in GRAPHS
            @bench "$(name): degree" LightGraphs.degree_centrality($g)
            @bench "$(name): closeness" LightGraphs.closeness_centrality($g)
            if nv(g) < 1000
                @bench "$(name): betweenness" LightGraphs.betweenness_centrality($g)
                @bench "$(name): katz" LightGraphs.katz_centrality($g)
            end
        end
    end #graphs
    @benchgroup "digraphs" begin
        for (name, g) in DIGRAPHS
            @bench "$(name): degree" LightGraphs.degree_centrality($g)
            @bench "$(name): closeness" LightGraphs.closeness_centrality($g)
            if nv(g) < 1000
                @bench "$(name): betweenness" LightGraphs.betweenness_centrality($g)
                @bench "$(name): katz" LightGraphs.katz_centrality($g)
            end
            if nv(g) < 500
                @bench "$(name): pagerank" LightGraphs.pagerank($g)
            end
        end
    end # digraphs
end # centrality
