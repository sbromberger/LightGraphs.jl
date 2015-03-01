# @doc doc"""
#         betweenness_centrality(g::AbstractGraph, k::Integer=0; normalize=true, endpoints=false)
#
#     Computes betweenness centrality of a graph, based on all vertices (default)
#     or on a specified subset.
#     """ ->
function betweenness_centrality(
    g::AbstractGraph,
    k::Integer=0;
    normalize=true,
    endpoints=false)

    n_v = nv(g)
    is_directed = (typeof(g) == DiGraph)

    betweenness = zeros(n_v)
    if k == 0
        nodes = 1:n_v
    else
        nodes = sample(1:n_v, k, replace=false)   #112
    end
    for si in nodes
        s = vertices(g)[si]
        # if length(weights) == 0
        #     state = dijkstra_predecessor_and_distance(g, s)
        # else
            state = dijkstra_predecessor_and_distance(g, s)
        # end
        if endpoints            # 120
            betweenness = _accumulate_endpoints(betweenness, state, g, si)
        else
            betweenness = _accumulate_basic(betweenness, state, g, si)
        end
    end
    betweenness = _rescale(betweenness, n_v,
                           normalize,
                           is_directed,
                           k)

    return betweenness
end


function _accumulate_basic(
    betweenness::Vector{Float64},
    state::DijkstraStateWithPred,
    g::AbstractGraph,
    si::Integer
    )

    nv = length(state.parents) # this is the ttl number of vertices
    δ = zeros(nv)
    σ = state.pathcounts
    P = state.predecessors

    # make sure the source index has no parents.
    P[si] = []
    # we need to order the source nodes by decreasing distance for this to work.
    v1 = [1:nv;]
    v2 = state.dists
    S = Int[x[2] for x in sort(collect(zip(v2,v1)), rev=true)]
    # println("S = $S, P = $P, σ = $σ, si = $si")
    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        # println("coeff of $w = $coeff, δ[w] = $(δ[w])")
        # println("*** P[w] = P[$w] = $(P[w])")
        for v in P[w]
            if v > 0
                δ[v] += (σ[v] * coeff)
                # println("setting δ[$vi] to $(δ[vi]), δ = $δ")
            end
        end
        if w != si
            betweenness[w] += δ[w]
        end
    end
    return betweenness
end

function _accumulate_endpoints(
    betweenness::Vector{Float64},
    state::DijkstraStateWithPred,
    g::AbstractGraph,
    si::Integer
    )

    nv = length(state.parents) # this is the ttl number of vertices
    δ = zeros(nv)
    σ = state.pathcounts
    P = state.predecessors
    v1 = [1:nv;]
    v2 = state.dists
    # v1 = [1:nv][state.hasparent] # the state.hasparent will fix P[si] = [] when it's merged
    # v2 = state.dists[state.hasparent]
    S = Int[x[2] for x in sort(collect(zip(v2,v1)), rev=true)]
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
    return betweenness
end

function _rescale(betweenness::Vector{Float64}, n::Int, normalize::Bool, directed::Bool, k::Int)
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
            do_scale = false    # 328
        end
    end
    if do_scale
        if k > 0
            scale = scale * n / k   #331
        end
        for v = 1:length(betweenness)
            betweenness[v] *= scale
        end
    end
    return betweenness      # 334
end
