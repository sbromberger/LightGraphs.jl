"""
    struct Tarjan <: StrongConnectivityAlgorithm

A struct representing a [`StrongConnectivityAlgorithm`](@ref)
based on Tarjan's strong connectivity algorithm.
"""
struct Tarjan <: StrongConnectivityAlgorithm end

mutable struct TarjanState{T<:Integer} <: LightGraphs.Traversals.TraversalState
    lastnode::T
    up::Bool
    stack::Vector{T}
    low::Vector{T}
    order::Vector{T}
    onstack::BitVector
    cnt::T
    comps::Vector{Vector{T}}
end

@inline function initfn!(s::TarjanState, u)
    s.up = false
    push!(s.stack, u)
    return true
end

@inline function previsitfn!(s::TarjanState{T}, u) where T
    if  s.up
        s.low[u] = min(s.low[u], s.low[s.lastnode])
    else
        push!(s.stack, u)
        s.up = true
        s.onstack[u] = true
        s.cnt += one(T)
        s.low[u] = s.order[u] = s.cnt
    end
    s.lastnode = u
    return true
end

@inline function newvisitfn!(s::TarjanState, u, v)
    s.up = false
    return true
end

@inline function visitfn!(s::TarjanState, u, v)
    if s.onstack[v]
        s.low[u] = min(s.order[v], s.low[u])
    end
    return true
end

@inline function postlevelfn!(s::TarjanState{T}) where T
    v = s.lastnode
    if s.low[v] == s.order[v]
        new_component = Vector{T}()
        a = T(0)
        while a != v
            a = pop!(s.stack)
            s.onstack[a] = false
            push!(new_component, a)
        end
        reverse!(new_component)
        push!(s.comps, new_component)
    end
    return true
end

@traitfn function connected_components(g::AG::IsDirected, ::Tarjan) where {T<:Integer, AG<:AbstractGraph{T}}
    state = TarjanState(T(0), false, Vector{T}(), zeros(T, nv(g)), zeros(T, nv(g)), falses(nv(g)), T(0), Vector{Vector{T}}())
    LightGraphs.Traversals.traverse_graph!(g, vertices(g), LightGraphs.Traversals.DepthFirst(), state)
    return state.comps
end
