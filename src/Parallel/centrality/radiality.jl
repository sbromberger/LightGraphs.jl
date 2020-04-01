function radiality_centrality(g::AbstractGraph; parallel=:distributed)::Vector{Float64}
    Base.depwarn("radiality_centrality is deprecated. Equivalent functionality has been moved to `LightGraphs.Centrality.centrality`.", :radiality_centrality)
    alg = parallel == :distributed ?
        LightGraphs.Centrality.DistributedRadiality() :
        LightGraphs.Centrality.ThreadedRadiality() 

    LightGraphs.Centrality.centrality(g, alg)
end
