#### REMOVE-2.0
function spfa_shortest_paths(
    graph::AbstractGraph{U},
    source::Integer,
    distmx::AbstractMatrix{T}=weights(graph)
    ) where T<:Real where U<:Integer

    Base.depwarn("`spfa_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :spfa_shortest_paths)

    LightGraphs.ShortestPaths.shortest_paths(graph, source, distmx, LightGraphs.ShortestPaths.SPFA())
end

function has_negative_edge_cycle_spfa(x...)
    Base.depwarn("`has_negative_edge_cycle_spfa` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.has_negative_weight_cycle`.", :has_negative_edge_cycle_spfa)
    LightGraphs.ShortestPaths.has_negative_weight_cycle(x...)
end
