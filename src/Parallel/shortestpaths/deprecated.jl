# TODO 2.0.0: Remove this file

function bellman_ford_shortest_paths(
    g::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}=weights(g)
    ) where T<:Real where U<:Integer

    Base.depwarn("`Parallel.bellman_ford_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :bellman_ford_shortest_paths)
    LightGraphs.ShortestPaths.shortest_paths(g, sources, distmx, LightGraphs.ShortestPaths.ThreadedBellmanFord())
end

function dijkstra_shortest_paths(g::AbstractGraph{U},
    sources::AbstractVector=vertices(g),
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real where U

    Base.depwarn("`Parallel.dijkstra_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :dijkstra_shortest_paths)
    LightGraphs.ShortestPaths.shortest_paths(g, sources, distmx, LightGraphs.ShortestPaths.DistributedDijkstra())
end


function floyd_warshall_shortest_paths(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T}=weights(g)
) where T<:Real where U<:Integer

    Base.depwarn("`Parallel.floyd_warshall_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :floyd_warshall_shortest_paths)
    LightGraphs.Parallel.shortest_paths(g, distmx, LightGraphs.ShortestPaths.ThreadedFloydWarshall())
end


function johnson_shortest_paths(g::AbstractGraph{U},
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real where U
    Base.depwarn("`Parallel.johnson_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :johnson_shortest_paths)
    LightGraphs.ShortestPaths.shortest_paths(g, distmx, LightGraphs.ShortestPaths.DistributedJohnson())
end
