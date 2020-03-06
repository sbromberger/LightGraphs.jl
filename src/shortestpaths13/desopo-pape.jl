# TODO 2.0.0: Remove this file
function desopo_pape_shortest_paths(g::AbstractGraph,
    src::Integer,
    distmx::AbstractMatrix{T} = weights(g)) where T <: Real
    Base.depwarn("`desopo_pape_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :desopo_pape_shortest_paths)
    LightGraphs.ShortestPaths.shortest_paths(g, src, distmx, LightGraphs.ShortestPaths.DEsopoPape())
end
