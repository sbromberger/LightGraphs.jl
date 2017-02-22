# Betweenness centrality measures
# TODO - weighted, separate unweighted, edge betweenness


doc"""
    betweenness_centrality(g, k=0; normalize=true, endpoints=false)


Calculates the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) of
the graph `g`, or, optionally, of a random subset of `k` vertices. Can
optionally include endpoints in the calculations. Normalization is enabled by
default.

Betweenness centrality is defined as:

$bc(v) = \frac{1}{\mathcal{N}} \sum_{s \neq t \neq v}
        \frac{\sigma_{st}(v)}{\sigma_{st}}$.

 **Parameters**

g: SimpleGraph
    A Graph, directed or undirected.

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

**Returns**

betweenness: Array{Float64}
    Betweenness centrality value per node id.


**References**

[1] Brandes 2001 & Brandes 2008
"""
function betweenness_centrality(
    g::SimpleGraph,
    nodes::AbstractArray{Int, 1} = vertices(g);
    normalize=true,
    endpoints=false)

    n_v = nv(g)
    k = length(nodes)
    isdir = is_directed(g)

    betweenness = zeros(n_v)
    for s in nodes
        if degree(g,s) > 0  # this might be 1?
            state = dijkstra_shortest_paths(g, s; allpaths=true)
            if endpoints
                _accumulate_endpoints!(betweenness, state, g, s)
            else
                _accumulate_basic!(betweenness, state, g, s)
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

betweenness_centrality(g::SimpleGraph, k::Int; normalize=true, endpoints=false) =
    betweenness_centrality(g, sample(vertices(g), k); normalize=normalize, endpoints=endpoints)



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
    s = g.vertices[si]
    betweenness[s] += length(S) - 1    # 289

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

function _rescale!(betweenness::Vector{Float64}, n::Int, normalize::Bool, directed::Bool, k::Int)
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
