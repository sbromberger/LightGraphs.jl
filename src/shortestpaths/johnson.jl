#### REMOVE-2.0
function johnson_shortest_paths(g::AbstractGraph{U},
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real where U <: Integer
    Base.depwarn("`johnson_shortest_paths` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.shortest_paths`.", :johnson_shortest_paths)

    LightGraphs.ShortestPaths.shortest_paths(g, distmx, LightGraphs.ShortestPaths.Johnson())
end
