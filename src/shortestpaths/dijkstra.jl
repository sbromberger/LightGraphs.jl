#### REMOVE-2.0
DijkstraState = LightGraphs.ShortestPaths.DijkstraResult

function dijkstra_shortest_paths(g::AbstractGraph,
    srcs::Vector{U},
    distmx::AbstractMatrix{T}=weights(g);
    allpaths=false,
    trackvertices=false
    ) where T <: Real where U <: Integer

    Base.depwarn("`dijkstra_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :dijkstra_shortest_paths)
    LightGraphs.ShortestPaths.shortest_paths(g, srcs, distmx, LightGraphs.ShortestPaths.Dijkstra(all_paths=allpaths, track_vertices=trackvertices))
end

dijkstra_shortest_paths(g::AbstractGraph, src::Integer, distmx::AbstractMatrix=weights(g); allpaths=false, trackvertices=false) =
dijkstra_shortest_paths(g, [src;], distmx; allpaths=allpaths, trackvertices=trackvertices)
