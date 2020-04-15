function local_clustering_coefficient(g::AbstractGraph, v=vertices(g))
  Base.depwarn("`local_clustering_coefficient` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.clustering_coefficient`.", :local_clustering_coefficient)
  LightGraphs.Community.clustering_coefficient(g, LightGraphs.Community.Local(v))
end

function local_clustering(g::AbstractGraph, v=vertices(g))
  Base.depwarn("`local_clustering` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.clustering`.", :local_clustering)
  LightGraphs.Community.clustering(g, LightGraphs.Community.Local(v))
end

function triangles(g::AbstractGraph, v=vertices(g))
  Base.depwarn("`triangles` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.clustering`.", :triangles)
  LightGraphs.Community.triangles(g, v)
end

function global_clustering_coefficient(g::AbstractGraph)
  Base.depwarn("`global_clustering_coefficient` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.clustering_coefficient`.", :global_clustering_coefficient)
  LightGraphs.Community.clustering_coefficient(g, LightGraphs.Community.Global())
end
