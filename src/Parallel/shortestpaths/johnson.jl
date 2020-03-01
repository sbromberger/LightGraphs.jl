function parallel_shortest_paths(g::AbstractGraph{U},
distmx::AbstractMatrix{T}, ::Johnson) where T <: Real where U <: Integer

    nvg = nv(g)
    type_distmx = typeof(distmx)
    #Change when parallel implementation of Bellman Ford available
    wt_transform = dists(shortest_paths(g, vertices(g), distmx, BellmanFord()))

    if !type_distmx.mutable && type_distmx !=  LightGraphs.DefaultDistance
        distmx = sparse(distmx) #Change reference, not value
    end

#Weight transform not needed if all weights are positive.
    if type_distmx !=  LightGraphs.DefaultDistance
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[src(e)] - wt_transform[dst(e)] 
        end
    end


    dijk_state = parallel_shortest_paths(g, vertices(g), distmx, Dijkstra())
    d = dists(dijk_state)
    p = parents(dijk_state)


    broadcast!(-, d, d, wt_transform)
    for v in vertices(g)
        d[:, v] .+= wt_transform[v] #Vertical traversal prefered
    end

    if type_distmx.mutable
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[dst(e)] - wt_transform[src(e)]
        end
    end

    return JohnsonResult(p, d)
end

parallel_shortest_paths(g::AbstractGraph, js::Johnson) = parallel_shortest_paths(g, weights(g), js)
