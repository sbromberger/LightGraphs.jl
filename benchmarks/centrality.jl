bg = BenchmarkGroup()
SUITE["centrality"] = bg

for (name, g) in GRAPHS
    bg["centrality","degree_centrality","graph","$name"] = @benchmarkable LightGraphs.degree_centrality($g)
    bg["centrality","closeness_centrality","graph","$name"] = @benchmarkable LightGraphs.closeness_centrality($g)
    if nv(g) < 1000
        bg["centrality","betweenness_centrality","graph","$name"] = @benchmarkable LightGraphs.betweenness_centrality($g)
        bg["centrality","katz_centrality","graph","$name"] = @benchmarkable LightGraphs.katz_centrality($g)
    end
end

for (name, g) in DIGRAPHS
    bg["centrality","degree_centrality","digraph","$name"] = @benchmarkable LightGraphs.degree_centrality($g)
    bg["centrality","closeness_centrality","digraph","$name"] = @benchmarkable LightGraphs.closeness_centrality($g)
    if nv(g) < 1000
        bg["centrality","betweenness_centrality","digraph","$name"] = @benchmarkable LightGraphs.betweenness_centrality($g)
        bg["centrality","katz_centrality","digraph","$name"] = @benchmarkable LightGraphs.katz_centrality($g)
        if nv(g) < 500
            bg["centrality","pagerank","digraph","$name"] = @benchmarkable LightGraphs.pagerank($g)
        end
    end
end
