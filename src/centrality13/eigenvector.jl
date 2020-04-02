function eigenvector_centrality(g::AbstractGraph)
    Base.depwarn("`eigenvector_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :eigenvector_centrality)
    alg = LightGraphs.Centrality.Eigenvector()
    LightGraphs.Centrality.centrality(g, alg)
end
