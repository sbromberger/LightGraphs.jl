"""
    struct ThreadedBetweenness{T<:AbstractVector{<:Integer}} <: CentralityMeasure
        normalize::Bool
        endpoints::Bool
        k::Int
        vs::T
    end
        
A struct representing a threaded algorithm to calculate the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality)
of a graph `g` across all vertices, a specified subset of vertices `vs`, and/or a random subset of `k` vertices. 

See [`Betweenness`](@ref) for usage examples.

### Optional Arguments
- `normalize=true`: If true, normalize the betweenness values by the
total number of possible distinct paths between all pairs in the graphs.
For an undirected graph, this number is ``\\frac{(|V|-1)(|V|-2)}{2}``
and for a directed graph, ``{(|V|-1)(|V|-2)}``.
- `endpoints=false`: If true, include endpoints in the shortest path count.
- `k=0`: If `k>0`, randomly sample `k` vertices from `vs` if provided, or from `vertices(g)` if empty.
- `vs=[]`: if `vs` is nonempty, run betweenness centrality only from these vertices.
"""
struct ThreadedBetweenness{T<:AbstractVector{<:Integer}} <: CentralityMeasure
    normalize::Bool
    endpoints::Bool
    k::Int
    vs::T
end

ThreadedBetweenness(; normalize=true, endpoints=false, k=0, vs=Vector{Int}()) = ThreadedBetweenness(normalize, endpoints, k, vs)

centrality(g::AbstractGraph, distmx::AbstractMatrix, alg::ThreadedBetweenness) = _threaded_betweenness_centrality(g, distmx, alg, true)
centrality(g::AbstractGraph, alg::ThreadedBetweenness) = _threaded_betweenness_centrality(g, zeros(0,0), alg, false)

function _threaded_betweenness_centrality(g::AbstractGraph,
    distmx::AbstractMatrix,
    alg::ThreadedBetweenness,
    use_dists::Bool)::Vector{Float64}

    vs = isempty(alg.vs) ? vertices(g) : alg.vs
    if alg.k > 0
        sample!(vs, alg.k)
    end

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    local_betweenness = [zeros(n_v) for i in 1:nthreads()]
    vs_active = findall((x)->degree(g, x) > 0, vs) # 0 might be 1?

    Base.Threads.@threads for s in vs_active
        state = use_dists ? ShortestPaths.shortest_paths(g, s, distmx, ShortestPaths.Dijkstra(all_paths=true, closest_vertices=true)) :
            ShortestPaths.shortest_paths(g, s, ShortestPaths.TrackingBFS())
        if alg.endpoints
            _accumulate_endpoints!(local_betweenness[Base.Threads.threadid()], state, g, s)
        else
            _accumulate_basic!(local_betweenness[Base.Threads.threadid()], state, g, s)
        end
    end
    betweenness = reduce(+, local_betweenness)

    _rescale!(betweenness, n_v, alg.normalize, isdir, k)

    return betweenness
end
