function stress_centrality(g::AbstractGraph, vs::AbstractVector=vertices(g); parallel=:distributed)::Vector{Int64}
    Base.depwarn("stress_centrality is deprecated. Equivalent functionality has been moved to `LightGraphs.Centrality.centrality`.", :stress_centrality)
    alg = parallel == :distributed ?
        LightGraphs.Centrality.DistributedStress(0, vs) :
        LightGraphs.Centrality.ThreadedStress(0, vs) 

    LightGraphs.Centrality.centrality(g, alg)
end

stress_centrality(g::AbstractGraph, k::Integer; parallel=:distributed) =
    stress_centrality(g, sample(vertices(g), k), parallel=parallel)
