# Betweenness centrality measures
# TODO - weighted, separate unweighted, edge betweenness



function singlethread_betweenness_centrality(
    g::SimpleGraph,
    k::Integer=0;
    normalize=true,
    endpoints=false)

    n_v = nv(g)
    isdir = is_directed(g)

    betweenness = zeros(n_v)
    if k == 0
        nodes = 1:n_v
    else
        nodes = sample(1:n_v, k, replace=false)   #112
    end
    for s in nodes
        state = singlethread_dijkstra_shortest_paths(g, s; allpaths=true)
        if endpoints
            _accumulate_endpoints!(betweenness, state, g, s)
        else
            _accumulate_basic!(betweenness, state, g, s)
        end
    end

    _rescale!(betweenness,
              n_v,
              normalize,
              isdir,
              k)

    return betweenness
end

function parallel_betweenness_centrality{T}(
    g::AbstractSparseGraph,
    k::Integer=0,
    distmx::AbstractArray{T,2} = DefaultDistance();
    normalize=true,
    endpoints=false)

    n_v = nv(g)
    isdir = is_directed(g)
    info("starting")
    spmx = share(g.fm)
    info("spmx set")
    if typeof(distmx) != LightGraphs.DefaultDistance
        distmx = share(distmx)
    else
        distmx = distmx[1:n_v, 1:n_v]
    end
    isdir = is_directed(g)
    betweenness = SharedArray(Float64, n_v, init=s->s[localindexes(s)] = 0.0)
    if k == 0
        nodes = 1:n_v
    else
        nodes = sample(1:n_v, k, replace=false)   #112
    end

    @sync @parallel for i in rangechunks(length(nodes), nworkers())
        for s in i
            state = dijkstra_shortest_paths_sparse(spmx, s, distmx, true)
            if endpoints
                _parallel_accumulate_endpoints!(betweenness, state, s)
            else
                _parallel_accumulate_basic!(betweenness, state, s)
            end
        end
    end
    _rescale!(betweenness,
              n_v,
              normalize,
              isdir,
              k)
    return betweenness
end

function _accumulate_basic!(
    betweenness::Vector{Float64},
    state::DijkstraState,
    g::SimpleGraph,
    si::Integer
    )

    n_v = length(state.parents) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = state.pathcounts
    P = state.predecessors

    # make sure the source index has no parents.
    P[si] = []
    # we need to order the source nodes by decreasing distance for this to work.
    S = sortperm(state.dists, rev=true)
    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        for v in P[w]
            if v > 0
                δ[v] += (σ[v] * coeff)
            end
        end
        if w != si
            betweenness[w] += δ[w]
        end
    end
end



function _accumulate_endpoints!(
    betweenness::Vector{Float64},
    state::DijkstraState,
    g::SimpleGraph,
    si::Integer
    )

    n_v = nv(g) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = state.pathcounts
    P = state.predecessors
    v1 = [1:n_v;]
    v2 = state.dists
    S = sortperm(state.dists, rev=true)
    betweenness[si] += length(S) - 1    # 289

    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        for v in P[w]
            δ[v] += σ[v] * coeff
        end
        if w != si
            betweenness[w] += (δ[w] + 1)
        end
    end
end

function _parallel_accumulate_basic!(
    betweenness::SharedArray{Float64,1},
    state::DijkstraState,
    si::Integer
    )

    n_v = length(state.parents) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = state.pathcounts
    P = state.predecessors

    # make sure the source index has no parents.
    P[si] = []
    # we need to order the source nodes by decreasing distance for this to work.
    S = sortperm(state.dists, rev=true)
    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        for v in P[w]
            if v > 0
                δ[v] += (σ[v] * coeff)
            end
        end
        if w != si
            betweenness[w] += δ[w]
        end
    end
end



function _parallel_accumulate_endpoints!(
    betweenness::SharedArray{Float64,1},
    state::DijkstraState,
    si::Integer
    )

    n_v = length(state.parents) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = state.pathcounts
    P = state.predecessors
    v1 = [1:n_v;]
    v2 = state.dists
    S = sortperm(state.dists, rev=true)

    betweenness[si] += length(S) - 1    # 289

    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        for v in P[w]
            δ[v] += σ[v] * coeff
        end
        if w != si
            betweenness[w] += (δ[w] + 1)
        end
    end
end


function _rescale!{T<:AbstractArray{Float64,1}}(betweenness::T, n::Int, normalize::Bool, directed::Bool, k::Int)
    if normalize
        if n <= 2
            do_scale = false
        else
            do_scale = true
            scale = 1.0 / ((n - 1) * (n - 2))
        end
    else
        if !directed
            do_scale = true
            scale = 1.0 / 2.0
        else
            do_scale = false
        end
    end
    if do_scale
        if k > 0
            scale = scale * n / k
        end
        for v = 1:length(betweenness)
            betweenness[v] *= scale
        end
    end
end

doc"""Calculates the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) of
the graph `g`, or, optionally, of a random subset of `k` vertices. Can
optionally include endpoints in the calculations. Normalization is enabled by
default.

Betweeness centrality is defined as:

$bc(v) = \frac{1}{\mathcal{N}}
        \sum_{s \neq t \neq v} \frac{\sigma_{st}(v)}{\sigma_{st}}$


#### Parameters

g: SimpleGraph
    A Graph, directed or undirected.

weights: AbstractArray{Float64, 2}, optional
    Matrix containing the weight associated with each edge (i,j)
    `ω[i, j]` is the weight between vertices `i` and `j`.
    If no weights are specified, shortest paths are computed using equal
    weights. If values are missing, they are assumed equal to `1`.
    *Advice* Use sparse matrices for better performances.

k: Integer, optional
    Use `k` nodes sample to estimate the betweenness centrality. If none,
    betweenness centrality is computed using the `n` nodes in the graph.

normalize: bool, optional
    If true, the betweenness values are normalized by the total number
    of possible distinct paths between all pairs in the graphs. For an undirected graph,
    this number if `((n-1)*(n-2))/2` and for a directed graph, `(n-1)*(n-2)`
    where `n` is the number of nodes in the graph.

endpoints: bool, optional
    If true, endpoints are included in the shortest path count.

#### Returns

betweenness: Array{Float64}
    Betweenness centrality value per node id.

#### Examples

#### References

[1] Brandes 2001 & Brandes 2008
"""
function betweenness_centrality(x...;y...)
    if _parallel
        parallel_betweenness_centrality(x...; y...)
    else
        singlethread_betweenness_centrality(x...; y...)
    end
end
