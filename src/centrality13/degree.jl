function degree_centrality(g::AbstractGraph; normalize=true)
    Base.depwarn("`degree_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :degree_centrality)
    alg = LightGraphs.Centrality.Degree(normalize=normalize, degreefn=degree)
    LightGraphs.Centrality.centrality(g, alg)
end

function indegree_centrality(g::AbstractGraph; normalize=true)
    Base.depwarn("`indegree_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :indegree_centrality)
    alg = LightGraphs.Centrality.Degree(normalize=normalize, degreefn=indegree)
    LightGraphs.Centrality.centrality(g, alg)
end

function outdegree_centrality(g::AbstractGraph; normalize=true)
    Base.depwarn("`outdegree_centrality` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :outdegree_centrality)
    alg = LightGraphs.Centrality.Degree(normalize=normalize, degreefn=outdegree)
    LightGraphs.Centrality.centrality(g, alg)
end
