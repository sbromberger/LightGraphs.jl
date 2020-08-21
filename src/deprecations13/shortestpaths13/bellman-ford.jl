# TODO 2.0.0: Remove this file
function bellman_ford_shortest_paths(
    graph::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}=weights(graph)
    ) where T<:Real where U<:Integer

    Base.depwarn("`bellman_ford_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :bellman_ford_shortest_paths)
    LightGraphs.ShortestPaths.shortest_paths(graph, sources, distmx, LightGraphs.ShortestPaths.BellmanFord())
end
bellman_ford_shortest_paths(
    graph::AbstractGraph{U},
    v::Integer,
    distmx::AbstractMatrix{T} = weights(graph);
    ) where T<:Real where U<:Integer = bellman_ford_shortest_paths(graph, [v], distmx)

@deprecate has_negative_edge_cycle LightGraphs.ShortestPaths.has_negative_weight_cycle
@deprecate enumerate_paths LightGraphs.ShortestPaths.paths
