function radiality_centrality(g::AbstractGraph)::Vector{Float64}
    Base.depwarn("`radiality_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :radiality_centrality)
    alg = LightGraphs.Centrality.Radiality()
    LightGraphs.Centrality.centrality(g, alg)
end
