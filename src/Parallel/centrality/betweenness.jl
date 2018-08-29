betweenness_centrality(g::AbstractGraph, vs::AbstractVector=vertices(g), distmx::AbstractMatrix=weights(g); normalize=true, endpoints=false, parallel=:distributed) = 
parallel == :distributed ? distr_betweenness_centrality(g, vs, distmx; normalize=normalize, endpoints=endpoints) : 
threaded_betweenness_centrality(g, vs, distmx; normalize=normalize, endpoints=endpoints)
    
betweenness_centrality(g::AbstractGraph, k::Integer, distmx::AbstractMatrix=weights(g); normalize=true, endpoints=false, parallel=:distributed) = 
parallel == :distributed ? distr_betweenness_centrality(g, sample(vertices(g), k), distmx; normalize=normalize, endpoints=endpoints) :
threaded_betweenness_centrality(g, sample(vertices(g), k), distmx; normalize=normalize, endpoints=endpoints)

function distr_betweenness_centrality(g::AbstractGraph,
    vs::AbstractVector=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false)::Vector{Float64}

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction

    betweenness = @distributed (+) for s in vs
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

distr_betweenness_centrality(g::AbstractGraph, k::Integer, distmx::AbstractMatrix=weights(g); normalize=true, endpoints=false) =
    distr_betweenness_centrality(g, sample(vertices(g), k), distmx; normalize=normalize, endpoints=endpoints)

function threaded_betweenness_centrality(g::AbstractGraph,
    vs::AbstractVector=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false)::Vector{Float64}

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    local_betweenness = [zeros(n_v) for i in 1:nthreads()]
    vs_active = findall((x)->degree(g, x) > 0, vs) # 0 might be 1?

    Base.Threads.@threads for s in vs_active
        state = LightGraphs.dijkstra_shortest_paths(g, s, distmx; allpaths=true, trackvertices=true)
        if endpoints
            LightGraphs._accumulate_endpoints!(local_betweenness[Base.Threads.threadid()], state, g, s)
        else
            LightGraphs._accumulate_basic!(local_betweenness[Base.Threads.threadid()], state, g, s)
        end
    end
    betweenness = reduce(+, local_betweenness)

    LightGraphs._rescale!(betweenness,
    n_v,
    normalize,
    isdir,
    k)

    return betweenness
end

threaded_betweenness_centrality(g::AbstractGraph, k::Integer, distmx::AbstractMatrix=weights(g); normalize=true, endpoints=false) =
    threaded_betweenness_centrality(g, sample(vertices(g), k), distmx; normalize=normalize, endpoints=endpoints)
