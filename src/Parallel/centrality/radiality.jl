function radiality_centrality(g::AbstractGraph; parallel=:distributed)
    Base.depwarn("radiality_centrality is deprecated. Equivalent functionality has been moved to `LightGraphs.Centrality.centrality`.", :radiality_centrality)
    alg = parallel == :distributed ?
        LightGraphs.Centrality.DistributedRadiality() :
        LightGraphs.Centrality.ThreadededRadiality() 

    LightGraphs.Centrality.centrality(g, alg)
end
