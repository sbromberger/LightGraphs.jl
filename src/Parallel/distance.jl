# used in shortest path calculations

function eccentricity(g::AbstractGraph,
    vs::AbstractVector=vertices(g),
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real
    vlen = length(vs)
    eccs = SharedVector{T}(vlen)
    @sync @distributed for i = 1:vlen
        eccs[i] = maximum(LightGraphs.dijkstra_shortest_paths(g, vs[i], distmx).dists)
    end
    d = sdata(eccs)
    maximum(d) == typemax(T) && warn("Infinite path length detected")
    return d
end

eccentricity(g::AbstractGraph, distmx::AbstractMatrix) =
    eccentricity(g, vertices(g), distmx)

diameter(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    maximum(eccentricity(g, distmx))

periphery(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    LightGraphs.periphery(eccentricity(g, distmx))

radius(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    minimum(eccentricity(g, distmx))

center(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    LightGraphs.center(eccentricity(g, distmx))
