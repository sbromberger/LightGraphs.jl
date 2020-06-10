mutable struct BridgeState{T<:Integer} <: TraversalState
    timer::T
    disc::Vector{T}
    low::Vector{T}
    prnt::Vector{T}
    nbr::Vector{T}
    bridges::Vector{SimpleEdge{T}}
end

function BridgeState(n::T) where T <: Integer
    disc = zeros(T, n)
    low = Vector{T}(undef, n)
    prnt = Vector{T}(undef, n)
    nbr = Vector{T}(undef, n)
    BridgeState(one(T), disc, low, prnt, nbr, Vector{SimpleEdge{T}}())
end

function previsitfn!(state::BridgeState{T}, u::T) where T <: Integer
    if state.disc[u] == 0
        state.low[u] = state.timer
        state.disc[u] = state.timer
        state.timer += 1
    else
        v = state.nbr[u]
        state.low[u] = min(state.low[u], state.low[v])
        if state.low[v] > state.disc[u]
            push!(state.bridges, Edge(min(u, v), max(u, v)))
        end
    end
    return VSUCCESS
end

function newvisitfn!(state::BridgeState{T}, u::T, v::T) where T <: Integer
    state.prnt[v] = u
    state.nbr[u] = v
    return VSUCCESS
end

function revisitfn!(state::BridgeState{T}, u::T, v::T) where T <: Integer
    if v != state.prnt[u]
        state.low[u] = min(state.low[u], state.disc[v])
    end
    return VSUCCESS
end

"""
    bridges(g)

Compute the [bridges](https://en.m.wikipedia.org/wiki/Bridge_(graph_theory))
of a connected graph `g` and return an array containing all bridges, i.e edges
whose deletion increases the number of connected components of the graph.

# Examples
```jldoctest
julia> using LightGraphs

julia> bridges(star_graph(5))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 1 => 4
 Edge 1 => 5

julia> bridges(path_graph(5))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 4 => 5
 Edge 3 => 4
 Edge 2 => 3
 Edge 1 => 2
```
"""
function bridges end
@traitfn function bridges(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}}
    state = BridgeState(T(nv(g)))
    @inbounds for u in vertices(g)
        if state.disc[u] == 0
            state.timer = 1
            state.prnt[u] = 0
            traverse_graph!(g, u, DepthFirst(), state)
        end
    end
    return state.bridges
end
