function yen_k_shortest_paths(g::AbstractGraph,
    source::U,
    target::U,
    distmx::AbstractMatrix{T}=weights(g),
    K::Int=1;
    maxdist=Inf) where T <: Real where U <: Integer
    Base.depwarn("`yen_k_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :yen_k_shortest_paths)
    LightGraphs.ShortestPaths.shortest_paths(g, source, target, distmx, LightGraphs.ShortestPaths.Yen(k=K, maxdist=maxdist))
end
