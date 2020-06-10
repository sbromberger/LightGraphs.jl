mutable struct ArticulationState{T<:Integer} <: TraversalState
    s::T
    timer::T
    nchildren::T
    disc::Vector{T}
    low::Vector{T}
    prnt::Vector{T}
    nbr::Vector{T}
    is_ap::BitVector
end

function ArticulationState(n::T) where T <: Integer
    disc = zeros(T, n)
    low = Vector{T}(undef, n)
    prnt = Vector{T}(undef, n)
    nbr = Vector{T}(undef, n)
    return ArticulationState(zero(T), one(T), zero(T), disc, low, prnt, nbr, falses(n))
end

function previsitfn!(state::ArticulationState{T}, u::T) where T <: Integer
    if state.disc[u] == 0
        state.low[u] = state.timer
        state.disc[u] = state.timer
        state.timer += 1
    else
        state.low[u] = min(state.low[u], state.low[state.nbr[u]])
        if state.prnt[u] != 0 && state.low[state.nbr[u]] >= state.disc[u]
            state.is_ap[u] = true
        end
    end
    return VSUCCESS
end

function newvisitfn!(state::ArticulationState{T}, u::T, v::T) where T <: Integer
    state.prnt[v] = u
    state.nbr[u] = v
    if u == state.s
        state.nchildren += 1
    end
    return VSUCCESS
end

function revisitfn!(state::ArticulationState{T}, u::T, v::T) where T <: Integer
    if v != state.prnt[u]
        state.low[u] = min(state.low[u], state.disc[v])
    end
    return VSUCCESS
end

"""
    articulation(g)

Compute the [articulation points](https://en.wikipedia.org/wiki/Biconnected_component)
of a connected graph `g` and return an array containing all cut vertices.

# Examples
```jldoctest
julia> using LightGraphs

julia> articulation(star_graph(5))
1-element Array{Int64,1}:
 1

julia> articulation(path_graph(5))
3-element Array{Int64,1}:
 2
 3
 4
```
"""
function articulation end
@traitfn function articulation(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}}
    state = ArticulationState(T(nv(g)))
    for u in vertices(g)
        if state.disc[u] == 0
            state.s = u
            state.timer = 1
            state.nchildren = 0
            state.prnt[u] = 0
            traverse_graph!(g, u, DepthFirst(), state)
            if state.nchildren > 1
                state.is_ap[u] = true
            end
        end
    end
    articulation_points = Vector{T}()
    for u in vertices(g)
        if state.is_ap[u]
            push!(articulation_points, u)
        end
    end
    return articulation_points
end
