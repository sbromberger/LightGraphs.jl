function betweenness_centrality(g::AbstractGraph,
    vs::AbstractVector=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false)

    Base.depwarn("`betweenness_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :betweenness_centrality)
    alg = LightGraphs.Centrality.Betweenness(vs=vs, normalize=normalize, endpoints=endpoints)
    LightGraphs.Centrality.centrality(g, distmx, alg)
end

betweenness_centrality(g::AbstractGraph, k::Integer, distmx::AbstractMatrix=weights(g); normalize=true, endpoints=false) =
    betweenness_centrality(g, sample(vertices(g), k), distmx; normalize=normalize, endpoints=endpoints)

