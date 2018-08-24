function betweenness_centrality(g::AbstractGraph,
    vs::AbstractVector=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false)::Vector{Float64}

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction

    betweenness = @distributed (+) for s in Int.(vs)
        temp_betweenness = zeros(n_v)
        if degree(g, s) > 0  # this might be 1?
            state = LightGraphs.dijkstra_shortest_paths(g, s, distmx; allpaths=true, trackvertices=true)
            if endpoints
                LightGraphs._accumulate_endpoints!(temp_betweenness, state, g, s)
            else
                LightGraphs._accumulate_basic!(temp_betweenness, state, g, s)
            end
        end
        temp_betweenness
    end

    LightGraphs._rescale!(betweenness,
    n_v,
    normalize,
    isdir,
    k)

    return betweenness
end

betweenness_centrality(g::AbstractGraph, k::Integer, distmx::AbstractMatrix=weights(g); normalize=true, endpoints=false) =
    betweenness_centrality(g, sample(vertices(g), k), distmx; normalize=normalize, endpoints=endpoints)
