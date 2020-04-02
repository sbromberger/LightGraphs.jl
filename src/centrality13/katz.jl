function katz_centrality(g::AbstractGraph, α::Real=0.3)
    Base.depwarn("`katz_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :katz_centrality)
    alg = LightGraphs.Centrality.Katz(α=α)
    LightGraphs.Centrality.centrality(g, alg)
end
