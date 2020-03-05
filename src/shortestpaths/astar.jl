#### REMOVE-2.0
function a_star(g::AbstractGraph{U},  # the g
    s::Integer,                       # the start vertex
    t::Integer,                       # the end vertex
    distmx::AbstractMatrix{T}=weights(g),
    heuristic::Function=(x, y) -> zero(T)) where {T, U}

    Base.depwarn("`a_star` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :a_star)
    LightGraphs.ShortestPaths.shortest_paths(g, s, t, distmx, LightGraphs.ShortestPaths.AStar(heuristic))
end
