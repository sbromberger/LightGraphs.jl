function closeness_centrality(g::AbstractGraph,
    distmx::AbstractMatrix=weights(g);
    normalize=true)

    Base.depwarn("`closeness_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :closeness_centrality)
    alg = LightGraphs.Centrality.Closeness(normalize=normalize)
    LightGraphs.Centrality.centrality(g, distmx, alg)
end
