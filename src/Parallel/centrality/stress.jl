function stress_centrality(g::AbstractGraph,
    vs::AbstractVector=vertices(g))::Vector{Int}

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction
    stress = @distributed (+) for s in vs
        temp_stress = zeros(Int, n_v)
        if degree(g, s) > 0  # this might be 1?
            state = LightGraphs.dijkstra_shortest_paths(g, s; allpaths=true, trackvertices=true)
            LightGraphs._stress_accumulate_basic!(temp_stress, state, g, s)
        end
        temp_stress
    end
    return stress
end

stress_centrality(g::AbstractGraph, k::Integer) =
    stress_centrality(g, sample(vertices(g), k))
    