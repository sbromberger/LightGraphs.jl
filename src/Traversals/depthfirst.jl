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
    state::AbstractTraversalState,
    ) where U<:Integer

    n = nv(g)
    visited = falses(n)
    S = Vector{Tuple{U,U}}()
    sizehint!(S, length(ss))
    preinitfn!(state, visited) || return false
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(S, (us, 0))
        initfn!(state, us) || return false
    end

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
    return true
end

mutable struct TopoSortState{T<:Integer} <: AbstractTraversalState
    vcolor::Vector{UInt8}
    verts::Vector{T}
    w::T
end

# 1 = visited
# 2 = vcolor 2
# @inline initfn!(s::TopoSortState{T}, u) where T = s.vcolor[u] = one(T)
@inline function previsitfn!(s::TopoSortState{T}, u) where T
    s.w = 0
    return true
end
@inline function visitfn!(s::TopoSortState{T}, u, v) where T
    return s.vcolor[v] != one(T)
end
@inline function newvisitfn!(s::TopoSortState{T}, u, v) where T
    s.w = v
    return true
end
@inline function postvisitfn!(s::TopoSortState{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
        push!(s.verts, u)
    end
    return true
end


@traitfn function topological_sort(g::AG::IsDirected, alg::DepthFirst=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    state = TopoSortState(vcolor, verts, zero(T))
    for v in vertices(g)
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        if !traverse_graph!(g, v, DepthFirst(), state)
            throw(CycleError())
        end
    end
    return reverse(state.verts)
end

mutable struct CycleState{T<:Integer} <: AbstractTraversalState
    vcolor::Vector{UInt8}
    w::T
end

@inline function previsitfn!(s::CycleState{T}, u) where T
    s.w = 0
    return true
end
@inline function visitfn!(s::CycleState{T}, u, v) where T
    return s.vcolor[v] != one(T)
end
@inline function newvisitfn!(s::CycleState{T}, u, v) where T
    s.w = v
    return true
end
@inline function postvisitfn!(s::CycleState{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
    end
    return true
end

@traitfn function is_cyclic(g::AG::IsDirected, alg::DepthFirst=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    state = CycleState(vcolor, zero(T))
    @inbounds for v in vertices(g)
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        !traverse_graph!(g, v, DepthFirst(), state) && return true
    end
    return false
end

@traitfn is_cyclic(g::::(!IsDirected), alg::DepthFirst=DepthFirst()) = ne(g) > 0

############ toposort2
#
mutable struct TopoSortState2{T<:Integer} <: AbstractTraversalState
    vcolor::Vector{UInt8}
    verts::Vector{T}
    targetvert::T
    nneighs::T
end

function previsitfn!(s::TopoSortState2, u)
    s.targetvert = u
    s.nneighs = 0
    println("targeting $u")
    return true
end

function newvisitfn!(s::TopoSortState2, u, v)
    s.nneighs += 1
    println("nneighs now $(s.nneighs)")
    s.vcolor[v] = max(1, s.vcolor[v])
    return true
end

function postlevelfn!(s::TopoSortState2)
    if s.nneighs == 0 && s.vcolor[s.targetvert] != 2
        println("no neighbors")
        push!(s.verts, s.targetvert)
        s.vcolor[s.targetvert] = 2
        s.targetvert = 0
        s.nneighs = 0
    else
        println("postlevel with $(s.nneighs) neighbors")
    end
    return true
end

function toposort2(g)
    state = TopoSortState2(zeros(UInt8, nv(g)), Vector{eltype(g)}(), 0, 0)
    for v in vertices(g)
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        if !traverse_graph!(g, v, DepthFirst(), state)
            throw(CycleError())
        end
    end
    return reverse(state.verts)
    
end
