radiality_centrality(g::AbstractGraph; parallel=:distributed) = 
parallel == :distributed ? distr_radiality_centrality(g) : threaded_radiality_centrality(g)

function distr_radiality_centrality(g::AbstractGraph)::Vector{Float64}
    n_v = nv(g)
    vs = vertices(g)
    n = ne(g)
    meandists = SharedVector{Float64}(Int(n_v))
    maxdists = SharedVector{Float64}(Int(n_v))

    @sync @distributed for i = 1:n_v
        d = shortest_paths(g, vs[i], Dijkstra())
        maxdists[i] = maximum(dists(d))
        meandists[i] = sum(dists(d)) / (n_v - 1)
        nothing
    end
    dmtr = maximum(maxdists)
    radialities = collect(meandists)
    return ((dmtr + 1) .- radialities) ./ dmtr
end

function threaded_radiality_centrality(g::AbstractGraph)::Vector{Float64}
    n_v = nv(g)
    vs = vertices(g)
    n = ne(g)
    meandists = Vector{Float64}(undef, n_v)
    maxdists = Vector{Float64}(undef, n_v)

    Base.Threads.@threads for i in vertices(g)
        d = shortest_paths(g, vs[i], Dijkstra())
        maxdists[i] = maximum(dists(d))
        meandists[i] = sum(dists(d)) / (n_v - 1)
    end
    dmtr = maximum(maxdists)
    radialities = collect(meandists)
    return ((dmtr + 1) .- radialities) ./ dmtr
end
