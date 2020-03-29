function betweenness_centrality(g::AbstractGraph, vs::AbstractVector=vertices(g), distmx::AbstractMatrix=weights(g); normalize=true, endpoints=false, parallel=:distributed)
    Base.depwarn("betweenness_centrality is deprecated. Equivalent functionality has been moved to `LightGraphs.Centrality.centrality`.", :betweenness_centrality)
    alg = parallel == :distributed ?
        LightGraphs.Centrality.DistributedBetweenness(normalize, endpoints, 0, vs) :
        LightGraphs.Centrality.ThreadededBetweenness(normalize, endpoints, 0, vs) 

    LightGraphs.Centrality.centrality(g, distmx, alg)
end

betweenness_centrality(
                       g::AbstractGraph,
                       k::Integer,
                       distmx::AbstractMatrix=weights(g);
                       normalize=true,
                       endpoints=false,
                       parallel=:distributed) =
    betweenness_centrality(g, sample(vertices(g), k), distmx, normalize=normalize, endpoints=endpoints, parallel=parallel)
