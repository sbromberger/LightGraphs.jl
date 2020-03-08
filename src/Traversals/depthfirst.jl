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
    state::AbstractTraversalState
    ) where U<:Integer

    n = nv(g)
    visited = falses(n)
    S = Vector{Tuple{U,U}}()
    sizehint!(S, length(ss))
    preinitfn!(state, visited) || return false
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(S, (us, 1))
        initfn!(state, us) || return false
    end

    while !isempty(S)
        v, ptr = pop!(S)
        previsitfn!(state, v) || return false

        neighs = alg.neighborfn(g, v)
        @inbounds while ptr <= length(neighs)
            i = neighs[ptr]
            visitfn!(state, v, i) || return false
            if !visited[i]  # find the first unvisited neighbor
                newvisitfn!(state, v, i) || return false
                visited[i] = true
                push!(S, (v, ptr+1))
                push!(S, (i, 1))
                break
            end
            ptr += 1
        end
        if ptr > length(neighs)
            postvisitfn!(state, v) || return false
        end
    end
    return true
end

mutable struct TopoSortState{T<:Integer} <: AbstractTraversalState
    vis::BitArray
    rec::BitArray
    verts::Vector{T}
end

@inline function preinitfn!(s::TopoSortState, visited)
    visited .= s.vis
    return true
end
@inline function previsitfn!(s::TopoSortState, u)
    s.vis[u] = true
    s.rec[u] = true
    return true
end
@inline function visitfn!(s::TopoSortState, u, v)
    return !s.rec[v]
end
@inline function postvisitfn!(s::TopoSortState, u)
    s.rec[u] = false
    push!(s.verts, u)
    return true
end

@traitfn function topological_sort(g::AG::IsDirected, alg::DepthFirst=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    state = TopoSortState(falses(nv(g)), falses(nv(g)), Vector{T}())
    @inbounds for v in vertices(g)
        state.vis[v] && continue
        if !traverse_graph!(g, v, DepthFirst(), state)
            throw(CycleError())
        end
    end
    return reverse(state.verts)
end

mutable struct CycleState <: AbstractTraversalState
    vis::BitArray
    rec::BitArray
end

@inline function preinitfn!(s::CycleState, visited)
    visited .= s.vis
    return true
end
@inline function previsitfn!(s::CycleState, u)
    s.vis[u] = true
    s.rec[u] = true
    return true
end
@inline function visitfn!(s::CycleState, u, v)
    return !s.rec[v]
end
@inline function postvisitfn!(s::CycleState, u)
    s.rec[u] = false
    return true
end

@traitfn function is_cyclic(g::AG::IsDirected, alg::DepthFirst=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    state = CycleState(falses(nv(g)), falses(nv(g)))
    @inbounds for v in vertices(g)
        state.vis[v] && continue
        !traverse_graph!(g, v, DepthFirst(), state) && return true
    end
    return false
end

@traitfn is_cyclic(g::::(!IsDirected), alg::DepthFirst=DepthFirst()) = ne(g) > 0
