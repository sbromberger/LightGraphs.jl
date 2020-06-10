mutable struct BiconnectState{T<:Integer} <: TraversalState
    s::T
    timer::T
    nchildren::T
    disc::Vector{T}
    low::Vector{T}
    prnt::Vector{T}
    nbr::Vector{T}
    stk::Vector{SimpleEdge{T}}
    comps::Vector{Vector{SimpleEdge{T}}}
end

function BiconnectState(n::T) where T <: Integer
    disc = zeros(T, n)
    low = Vector{T}(undef, n)
    prnt = Vector{T}(undef, n)
    nbr = Vector{T}(undef, n)
    stk = Vector{SimpleEdge{T}}()
    comps = Vector{Vector{SimpleEdge{T}}}()
    return BiconnectState(zero(T), one(T), zero(T), disc, low, prnt, nbr, stk, comps)
end

function previsitfn!(state::BiconnectState{T}, u::T) where T <: Integer
    if state.disc[u] == 0
        state.low[u] = state.timer
        state.disc[u] = state.timer
        state.timer += 1
    else
        v = state.nbr[u]
        state.low[u] = min(state.low[u], state.low[v])
        if (u == state.s && state.nchildren > 1) ||
                    (state.prnt[u] != 0 && state.low[v] >= state.disc[u])
            x = Vector{SimpleEdge{T}}()
            e = SimpleEdge(u, v)
            while state.stk[end] != e
                a = pop!(state.stk)
                w, z = src(a), dst(a)
                push!(x, SimpleEdge(min(w, z), max(w, z)))
            end
            pop!(state.stk)
            push!(x, SimpleEdge(min(u, v), max(u, v)))
            push!(state.comps, x)
        end
    end
    return VSUCCESS
end

function newvisitfn!(state::BiconnectState{T}, u::T, v::T) where T <: Integer
    state.prnt[v] = u
    state.nbr[u] = v
    push!(state.stk, SimpleEdge{T}(u, v))
    if u == state.s
        state.nchildren += 1
    end
    return VSUCCESS
end

function revisitfn!(state::BiconnectState{T}, u::T, v::T) where T <: Integer
    if v != state.prnt[u]
        state.low[u] = min(state.low[u], state.disc[v])
        if state.disc[v] < state.disc[u]
            push!(state.stk, SimpleEdge{T}(u, v))
        end
    end
    return VSUCCESS
end


"""
    biconnected_components(g) -> Vector{Vector{Edge{eltype(g)}}}

Compute the [biconnected components](https://en.wikipedia.org/wiki/Biconnected_component)
of an undirected graph `g`and return a vector of vectors containing each
biconnected component.

Performance:
Time complexity is ``\\mathcal{O}(|V|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> biconnected_components(star_graph(5))
4-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 3]
 [Edge 1 => 4]
 [Edge 1 => 5]
 [Edge 1 => 2]

julia> biconnected_components(cycle_graph(5))
1-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 5, Edge 4 => 5, Edge 3 => 4, Edge 2 => 3, Edge 1 => 2]
```
"""
function biconnected_components end
@traitfn function biconnected_components(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}}
    state = BiconnectState(T(nv(g)))
    @inbounds for u in vertices(g)
        if state.disc[u] == 0
            state.s = u
            state.nchildren = 0
            state.prnt[u] = 0
            state.timer = 1
            traverse_graph!(g, u, DepthFirst(), state)
            if !isempty(state.stk)
                x = Vector{SimpleEdge{T}}()
                for i in length(state.stk):-1:1
                    w, z = src(state.stk[i]), dst(state.stk[i])
                    push!(x, SimpleEdge(min(w, z), max(w, z)))
                end
                push!(state.comps, x)
                empty!(state.stk)
            end
        end
    end
    return state.comps
end
