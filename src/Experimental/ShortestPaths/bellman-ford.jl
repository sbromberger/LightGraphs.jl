# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The Bellman Ford algorithm for single-source shortest path

###################################################################
#
#   The type that capsulates the state of Bellman Ford algorithm
#
###################################################################
struct NegativeCycleError <: Exception end

struct BellmanFord <: ShortestPathAlgorithm end
struct BellmanFordResult{T<:Real, U<:Integer} <: ShortestPathResult
    parents::Vector{U}
    dists::Vector{T}
end
"""
    bellman_ford_shortest_paths(g, s, distmx=weights(g))
    bellman_ford_shortest_paths(g, ss, distmx=weights(g))

Compute shortest paths between a source `s` (or list of sources `ss`) and all
other nodes in graph `g` using the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm).
Return a [`LightGraphs.BellmanFordState`](@ref) with relevant traversal information.
"""
function shortest_paths(
    graph::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T},
    ::BellmanFord
   ) where {T<:Real, U<:Integer}

    nvg = nv(graph)
    active = falses(nvg)
    active[sources] .= true
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[sources] .= 0
    no_changes = false
    new_active = falses(nvg)

    @inbounds for i in vertices(graph)
        no_changes = true
        new_active .= false
        for u in vertices(graph)[active]
            for v in outneighbors(graph, u)
                relax_dist = distmx[u, v] + dists[u]
                if dists[v] > relax_dist
                    dists[v] = relax_dist
                    parents[v] = u
                    no_changes = false
                    new_active[v] = true
                end
            end
        end
        no_changes && break
        active, new_active = new_active, active
    end
    no_changes || throw(NegativeCycleError())
    return BellmanFordResult(parents, dists)
end

shortest_paths(
    graph::AbstractGraph{U},
    v::Integer,
    distmx::AbstractMatrix{T},
    alg::BellmanFord
    ) where T<:Real where U<:Integer = shortest_paths(graph, [v], distmx, alg)

has_negative_weight_cycle(g::AbstractGraph, ::BellmanFord) = false

function has_negative_weight_cycle(
    g::AbstractGraph{U}, 
    distmx::AbstractMatrix{T},
    alg::BellmanFord
    ) where T<:Real where U<:Integer
    try
        shortest_paths(g, vertices(g), distmx, alg)
    catch e
        isa(e, ShortestPaths.NegativeCycleError) && return true
    end
    return false
end
