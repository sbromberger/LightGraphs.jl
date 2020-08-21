# TODO 2.0.0: Remove this file
function a_star(g::AbstractGraph{U},  # the g
    s::Integer,                       # the start vertex
    t::Integer,                       # the end vertex
    distmx::AbstractMatrix{T}=weights(g),
    heuristic::Function=(x, y) -> zero(T)) where {T, U}

    Base.depwarn("`a_star` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :a_star)
    p = first(LightGraphs.ShortestPaths.paths(LightGraphs.ShortestPaths.shortest_paths(g, s, t, distmx, LightGraphs.ShortestPaths.AStar(heuristic))))
    pathlist = Vector{LightGraphs.SimpleEdge}()
    for i = 1:length(p)-1
        push!(pathlist, LightGraphs.SimpleEdge(p[i], p[i+1]))
    end
    return pathlist
end
