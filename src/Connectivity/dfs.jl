"""
    struct DFS <: WeakConnectivityAlgorithm

A struct representing a [`WeakConnectivityAlgorithm`](@ref)
based on depth-first search.
"""
struct DFS <: WeakConnectivityAlgorithm end

mutable struct VisitedState{T<:Integer} <: LightGraphs.Traversals.TraversalState
    component_map::Vector{T}
    current_component::T
end

@inline function initfn!(state::VisitedState, u)
    state.component_map[u] = state.current_component
    return true
end

@inline function newvisitfn!(state::VisitedState, u, v)
    state.component_map[v] > 0 && return false
    state.component_map[v] = state.component_map[u]
    return true
end

@inline function postlevelfn!(state::VisitedState)
    state.current_component += 1
    return true
end

function connected_components(g::AbstractGraph{T}, ::DFS) where {T}
    state = VisitedState(zeros(T, nv(g)), one(T))
    LightGraphs.Traversals.traverse_graph!(g, vertices(g), LightGraphs.Traversals.DepthFirst(), state)
    return components(state.component_map)[1]
end

