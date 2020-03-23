import Base.showerror
struct CycleError <: Exception end
Base.showerror(io::IO, e::CycleError) = print(io, "Cycles are not allowed in this function.")



struct DepthFirst{F<:Function} <: TraversalAlgorithm
    neighborfn::F
end

DepthFirst(;neighborfn=outneighbors) = DepthFirst(neighborfn)

function traverse_graph!(
    g::AbstractGraph{U},
    ss::AbstractVector,
    alg::DepthFirst,
    state::TraversalState,
    ) where U<:Integer

    n = nv(g)
    visited = falses(n)
    S = Vector{Tuple{U, U}}()
    sizehint!(S, length(ss))
    preinitfn!(state, visited) || return false
    @inbounds for s in ss
        us = U(s)
        visited[us] && continue

        visited[us] = true
        push!(S, (us, 1))
        initfn!(state, us) || return false

        ptr = one(U)

        while !isempty(S)
            v, _ = S[end]
            previsitfn!(state, v) || return false

            neighs=alg.neighborfn(g, v)
            @inbounds while ptr <= length(neighs)
                i = neighs[ptr]
                visitfn!(state, v, i) || return false
                if !visited[i]  # find the first unvisited neighbor
                    newvisitfn!(state, v, i) || return false
                    visited[i] = true
                    push!(S, (i, ptr+1))
                    break
                end
                ptr += 1
            end
            postvisitfn!(state, v) || return false
            # if ptr > length(neighs) then we have finished all children of the node,
            # and the next time we pop from the stack we will be in the parent of the current
            # node. We would like to continue from where we stoped, otherwise we have found
            # a new unvisited child, so we will make ptr = 1
            if ptr > length(neighs)
                postlevelfn!(state) || return false
                _, ptr =pop!(S)
            else
                ptr = 1 # we will enter new node
            end
        end
    end


    return true
end


mutable struct TopoSortState{T<:Integer} <: TraversalState
    vcolor::Vector{UInt8}
    verts::Vector{T}
    w::T
end

# 1 = visited
# 2 = vcolor 2
# @inline initfn!(s::TopoSortState{T}, u) where T = s.vcolor[u] = one(T)
function previsitfn!(s::TopoSortState{T}, u) where T
    s.w = 0
    return true
end
function visitfn!(s::TopoSortState{T}, u, v) where T
    return s.vcolor[v] != one(T)
end
function newvisitfn!(s::TopoSortState{T}, u, v) where T
    s.w = v
    return true
end
function postvisitfn!(s::TopoSortState{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
        push!(s.verts, u)
    end
    return true
end


"""
    topological_sort(g, alg=DepthFirst())

Return a [topological sort](https://en.wikipedia.org/wiki/Topological_sorting) of a directed graph `g`
using [`TraversalAlgorithm`](@ref) `alg` as a vector of vertices in topological order.
"""
function topological_sort end

@traitfn function topological_sort(g::AG::IsDirected, alg::TraversalAlgorithm=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    state = TopoSortState(vcolor, verts, zero(T))
    sources = filter(x -> indegree(g, x) == 0, vertices(g))

    traverse_graph!(g, sources, DepthFirst(), state) || throw(CycleError())

    length(state.verts) < nv(g) && throw(CycleError())
    length(state.verts) > nv(g) && throw(TraversalError())
    return reverse!(state.verts)
end

mutable struct CycleState{T<:Integer} <: TraversalState
    vcolor::Vector{UInt8}
    w::T
end

function previsitfn!(s::CycleState{T}, u) where T
    s.w = 0
    return true
end
function visitfn!(s::CycleState{T}, u, v) where T
    return s.vcolor[v] != one(T)
end
function newvisitfn!(s::CycleState{T}, u, v) where T
    s.w = v
    return true
end
function postvisitfn!(s::CycleState{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
    end
    return true
end

@traitfn function is_cyclic(g::AG::IsDirected, alg::TraversalAlgorithm=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    state = CycleState(vcolor, zero(T))
    @inbounds for v in vertices(g)
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        !traverse_graph!(g, v, alg, state) && return true
    end
    return false
end

@traitfn is_cyclic(g::::(!IsDirected), alg::TraversalAlgorithm=DepthFirst()) = ne(g) > 0



mutable struct SccState{T <: Integer} <: TraversalState
    lastnode::T
    up::Bool
    stack::Vector{T}
    low::Vector{T}
    order::Vector{T}
    onstack::BitVector
    cnt::T
    comps::Vector{Vector{T}}
end

function initfn!(s::SccState, u)
    s.up = false
    push!(s.stack, u)
    return true
end


function previsitfn!(s::SccState{T}, u) where T
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

function newvisitfn!(s::SccState, u, v)
    s.up = false
    return true
end

function visitfn!(s::SccState, u, v)
    if s.onstack[v]
        s.low[u] = min(s.order[v], s.low[u])
    end
    return true
end

function postlevelfn!(s::SccState{T}) where T
    v = s.lastnode
    s.onstack[v] = false
    if s.low[v] == s.order[v]
        new_compnent = Vector{T}()
        a = T(0)
        while a != v
            a = pop!(s.stack)
            push!(new_compnent, a)
        end
        push!(s.comps, new_compnent)
    end
    return true
end

function tstrongly_connected_components(g::AG) where {T<:Integer, AG <: AbstractGraph{T}}
    state = SccState(T(0), false, Vector{T}(), zeros(T, nv(g)), zeros(T, nv(g)), falses(nv(g)), T(0), Vector{Vector{T}}())
    traverse_graph!(g, vertices(g), DepthFirst(), state)
    return state.comps
end


mutable struct ReverPotState{T <: Integer} <: TraversalState
    cnt::T
    lastnode::T
    result::Vector{T}
end

function previsitfn!(s::ReverPotState{T}, u) where T
    s.lastnode = u
    return true
end

function postlevelfn!(s::ReverPotState{T}) where T
    s.result[s.cnt] = s.lastnode
    s.cnt -= 1
    return true
end





mutable struct KosarajState{T <: Integer} <: TraversalState
    curr_comp::Vector{T}
    comps::Vector{Vector{T}}
end

function initfn!(s::KosarajState{T}, u) where T
    if !isempty(s.curr_comp)
        push!(s.comps, s.curr_comp)
    end
    s.curr_comp = Vector{T}([u])
    return true
end

function newvisitfn!(s::KosarajState, u, v)
    push!(s.curr_comp, v)
    return true
end



function tstrongly_connected_components_kosaraju(g::DiGraph{T}) where T<:Integer
    state = ReverPotState(nv(g), T(0), zeros(T, nv(g)))
    traverse_graph!(g, vertices(g), DepthFirst(), state)
    state2 = KosarajState(Vector{T}(), Vector{Vector{T}}())
    traverse_graph!(g, state.result, DepthFirst(inneighbors), state2)
    if !isempty(state2.curr_comp)
        push!(state2.comps, state2.curr_comp)
    end
    return state2.comps
end



mutable struct ConComps{T <: Integer} <: TraversalState
    head::T
    labels::Vector{T}
end

function newvisitfn!(s::ConComps, u, v)
    s.labels[v]
    return true
end
function initfn!(s::ConComps, u)
    s.labels[u] = s.head
end

function tconnected_components!(label::AbstractVector, g::AbstractGraph{T}) where T
    state = Concomps(0, label)
    traverse_graph!(g, vertices(g), DepthFirst(all_neighbors), state)
    return state.labels
end
