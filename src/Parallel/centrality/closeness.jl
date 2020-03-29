function closeness_centrality(g::AbstractGraph, distmx::AbstractMatrix=weights(g); normalize=true, parallel=:distributed)
    Base.depwarn("closeness_centrality is deprecated. Equivalent functionality has been moved to `LightGraphs.Centrality.centrality`.", :closeness_centrality)
    alg = parallel == :distributed ?
        LightGraphs.Centrality.DistributedCloseness(normalize) :
        LightGraphs.Centrality.ThreadededCloseness(normalize) 

    LightGraphs.Centrality.centrality(g, distmx, alg)
end
