"""
    struct Kosaraju <: StrongConnectivityAlgorithm

A struct representing a [`StrongConnectivityAlgorithm`](@ref)
based on Kosaraju's linear-time strong connectivity algorithm.
"""
struct Kosaraju <: StrongConnectivityAlgorithm end

mutable struct RevPostOrderState{T <: Integer} <: LightGraphs.Traversals.TraversalState
    cnt::T
    lastnode::T
    result::Vector{T}
end

@inline function previsitfn!(s::RevPostOrderState{T}, u) where T
    s.lastnode = u
    return true
end

@inline function postlevelfn!(s::RevPostOrderState{T}) where T
    s.result[s.cnt] = s.lastnode
    s.cnt -= 1
    return true
end

mutable struct KosarajuState{T <: Integer} <: LightGraphs.Traversals.TraversalState
    curr_comp::Vector{T}
    comps::Vector{Vector{T}}
end

@inline function initfn!(s::KosarajuState{T}, u) where T
    if !isempty(s.curr_comp)
        push!(s.comps, s.curr_comp)
    end
    s.curr_comp = Vector{T}([u])
    return true
end

@inline function newvisitfn!(s::KosarajuState, u, v)
    push!(s.curr_comp, v)
    return true
end

@traitfn function connected_components(g::AG::IsDirected, ::Kosaraju) where {T<:Integer, AG<:AbstractGraph{T}}
    state = RevPostOrderState(nv(g), T(0), zeros(T, nv(g)))
    LightGraphs.Traversals.traverse_graph!(g, vertices(g), LightGraphs.Traversals.DepthFirst(), state)
    state2 = KosarajuState(Vector{T}(), Vector{Vector{T}}())
    LightGraphs.Traversals.traverse_graph!(g, state.result, LightGraphs.Traversals.DepthFirst(neighborfn=inneighbors), state2)
    if !isempty(state2.curr_comp)
        push!(state2.comps, state2.curr_comp)
    end
    return state2.comps
end

