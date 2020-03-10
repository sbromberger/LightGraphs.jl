stress_centrality(
    g::AbstractGraph,
    vs::AbstractVector = vertices(g);
    parallel = :distributed,
) = parallel == :distributed ? distr_stress_centrality(g, vs) :
    threaded_stress_centrality(g, vs)

stress_centrality(g::AbstractGraph, k::Integer; parallel = :distributed) =
    parallel == :distributed ? distr_stress_centrality(g, sample(vertices(g), k)) :
    threaded_stress_centrality(g, sample(vertices(g), k))

function distr_stress_centrality(
    g::AbstractGraph,
    vs::AbstractVector = vertices(g),
)::Vector{Int64}

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction
    stress = @distributed (+) for s in vs
        temp_stress = zeros(Int64, n_v)
        if degree(g, s) > 0  # this might be 1?
            state = LightGraphs.dijkstra_shortest_paths(
                g,
                s;
                allpaths = true,
                trackvertices = true,
            )
            LightGraphs._stress_accumulate_basic!(temp_stress, state, g, s)
        end
        temp_stress
    end
    return stress
end

function threaded_stress_centrality(
    g::AbstractGraph,
    vs::AbstractVector = vertices(g),
)::Vector{Int64}

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction
    local_stress = [zeros(Int, n_v) for _ = 1:nthreads()]

    Base.Threads.@threads for s in vs
        if degree(g, s) > 0  # this might be 1?
            state = LightGraphs.dijkstra_shortest_paths(
                g,
                s;
                allpaths = true,
                trackvertices = true,
            )
            LightGraphs._stress_accumulate_basic!(
                local_stress[Base.Threads.threadid()],
                state,
                g,
                s,
            )
        end
    end
    return reduce(+, local_stress)
end
