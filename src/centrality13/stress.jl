function stress_centrality(g::AbstractGraph, k::Integer)
    Base.depwarn("`stress_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :stress_centrality)
    alg = LightGraphs.Centrality.Stress(k=k)
    LightGraphs.Centrality.centrality(g, alg)
end

function stress_centrality(g::AbstractGraph, vs::AbstractVector)
    Base.depwarn("`stress_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :stress_centrality)
    alg = LightGraphs.Centrality.Stress(vs=vs)
    LightGraphs.Centrality.centrality(g, alg)
end

function stress_centrality(g::AbstractGraph)
    Base.depwarn("`stress_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :stress_centrality)
    alg = LightGraphs.Centrality.Stress()
    LightGraphs.Centrality.centrality(g, alg)
end

