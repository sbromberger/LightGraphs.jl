#### REMOVE-2.0

function bellman_ford_shortest_paths(
    g::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}=weights(g)
    ) where T<:Real where U<:Integer

    Base.depwarn("`Parallel.bellman_ford_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.Parallel.shortest_paths`.", :bellman_ford_shortest_paths)
    LightGraphs.Parallel.shortest_paths(g, sources, distmx, LightGraphs.Parallel.ThreadedBellmanFord())
end


function dijkstra_shortest_paths(g::AbstractGraph{U},
    sources::AbstractVector=vertices(g),
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real where U

    Base.depwarn("`Parallel.dijkstra_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.Parallel.shortest_paths`.", :dijkstra_shortest_paths)
    LightGraphs.Parallel.shortest_paths(g, sources, distmx, LightGraphs.Parallel.ParallelDijkstra())
end


function floyd_warshall_shortest_paths(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T}=weights(g)
) where T<:Real where U<:Integer

    Base.depwarn("`Parallel.floyd_warshall_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.Parallel.shortest_paths`.", :floyd_warshall_shortest_paths)
    LightGraphs.Parallel.shortest_paths(g, distmx, LightGraphs.Parallel.ThreadedFloydWarshall())
end


function johnson_shortest_paths(g::AbstractGraph{U},
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real where U
    Base.depwarn("`Parallel.johnson_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.Parallel.shortest_paths`.", :johnson_shortest_paths)
    LightGraphs.Parallel.shortest_paths(g, distmx, LightGraphs.Parallel.ParallelJohnson())
end
