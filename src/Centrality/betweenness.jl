# Betweenness centrality measures
# TODO - edge betweenness

"""
    struct Betweenness{T<:AbstractVector{<:Integer}} <: CentralityMeasure
        normalize::Bool
        endpoints::Bool
        k::Int
        vs::T
    end
        
A struct representing an algorithm to calculate the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality)
of a graph `g` across all vertices, a specified subset of vertices `vs`, and/or a random subset of `k` vertices. 

### Optional Arguments
- `normalize=true`: If true, normalize the betweenness values by the
total number of possible distinct paths between all pairs in the graphs.
For an undirected graph, this number is ``\\frac{(|V|-1)(|V|-2)}{2}``
and for a directed graph, ``{(|V|-1)(|V|-2)}``.
- `endpoints=false`: If true, include endpoints in the shortest path count.
- `k=0`: If `k>0`, randomly sample `k` vertices from `vs` if provided, or from `vertices(g)` if empty.
- `vs=[]`: if `vs` is nonempty, run betweenness centrality only from these vertices.

Betweenness centrality is defined as:
``
bc(v) = \\frac{1}{\\mathcal{N}} \\sum_{s \\neq t \\neq v}
\\frac{\\sigma_{st}(v)}{\\sigma_{st}}
``.

### References
- Brandes 2001 & Brandes 2008

# Examples
```jldoctest
julia> using LightGraphs

julia> centrality(star_graph(3), Betweenness())
3-element Array{Float64,1}:
 1.0
 0.0
 0.0

 julia> centrality(path_graph(4), Betweenness())
4-element Array{Float64,1}:
 0.0
 0.6666666666666666
 0.6666666666666666
 0.0
```
"""
struct Betweenness{T<:AbstractVector{<:Integer}} <: CentralityMeasure
    normalize::Bool
    endpoints::Bool
    k::Int
    vs::T
end

Betweenness(; normalize=true, endpoints=false, k=0, vs=Vector{Int}()) = Betweenness(normalize, endpoints, k, vs)

centrality(g::AbstractGraph, distmx::AbstractMatrix, alg::Betweenness) = _betweenness_centrality(g, distmx, alg, true)

centrality(g::AbstractGraph, alg::Betweenness) = _betweenness_centrality(g, zeros(0,0), alg, false)

function _betweenness_centrality(g::AbstractGraph, distmx::AbstractMatrix, alg::Betweenness, use_dists::Bool)
    vs = isempty(alg.vs) ? vertices(g) : alg.vs
    if alg.k > 0
        sample!(vs, alg.k)
    end

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    betweenness = zeros(n_v)
    state = use_dists ? ShortestPaths.Dijkstra(all_paths=true, track_vertices=true) : ShortestPaths.TrackingBFS()
    for s in vs
        if degree(g, s) > 0  # this might be 1?
            result = use_dists ? ShortestPaths.shortest_paths(g, s, distmx, state) : ShortestPaths.shortest_paths(g, s, state)
            if alg.endpoints
                _accumulate_endpoints!(betweenness, result, g, s)
            else
                _accumulate_basic!(betweenness, result, g, s)
            end
        end
    end

    _rescale!(betweenness,
    n_v,
    alg.normalize,
    isdir,
    k)

    return betweenness
end

function _accumulate_basic!(betweenness::Vector{Float64},
    result::ShortestPaths.ShortestPathResult,  # we only really accept DijkstraResult and TrackingBFSResult.
    g::AbstractGraph,
    si::Integer)

    n_v = length(ShortestPaths.parents(result)) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = result.pathcounts   # these are unique to Dijkstra and TrackingBFS.
    P = result.predecessors

    # make sure the source index has no parents.
    P[si] = []
    # we need to order the source vertices by decreasing distance for this to work.
    S = reverse(result.closest_vertices) # Also unique to Dijkstra and TrackingBFS.
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
    return nothing
end

function _accumulate_endpoints!(betweenness::Vector{Float64},
    result::ShortestPaths.ShortestPathResult,  # we only really accept DijkstraResult and TrackingBFSResult.
    g::AbstractGraph,
    si::Integer)

    n_v = nv(g) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = result.pathcounts
    P = result.predecessors
    v1 = collect(Base.OneTo(n_v))
    v2 = result.dists
    S = reverse(result.closest_vertices)
    s = vertices(g)[si]
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
    return nothing
end

function _rescale!(betweenness::Vector{Float64}, n::Integer, normalize::Bool, directed::Bool, k::Integer)
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
        betweenness .*= scale
    end
    return nothing
end
