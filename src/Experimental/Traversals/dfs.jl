import Base.showerror
struct CycleError <: Exception end
Base.showerror(io::IO, e::CycleError) = print(io, "Cycles are not allowed in this function.")

struct DFS <: TraversalAlgorithm end

function traverse_graph!(
    g::AbstractGraph{U},
    ss::AbstractVector,
    alg::DFS,
    state::AbstractTraversalState,
    neighborfn::Function=outneighbors
    ) where U<:Integer
    
    n = nv(g)
    visited = falses(n)
    S = Vector{U}()
    sizehint!(S, length(ss))
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(S, us)
        initfn!(state, us) || return false
    end
    while !isempty(S)
        v = S[end]
        previsitfn!(state, v) || return false
        new_neighbor_found = false
        @inbounds for i in neighborfn(g, v)
            visitfn!(state, v, i) || return false
            if !visited[i]  # find the first unvisited neighbor
                newvisitfn!(state, v, i) || return false
                new_neighbor_found = true
                visited[i] = true
                push!(S, i)
                break
            end
        end
        postvisitfn!(state, v) || return false
        if !new_neighbor_found  # no more new neighbors. Let's go to the next source vertex.
            postlevelfn!(state) || return false
            pop!(S)
        end
    end
    return true
end

mutable struct TopoSortState{T<:Integer} <: AbstractTraversalState
    vcolor::Vector{UInt8}
    verts :: Vector{T}
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


@traitfn function topological_sort(g::AG::IsDirected) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    state = TopoSortState(vcolor, verts, zero(T))
    for v in vertices(g)
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        if !traverse_graph!(g, v, DFS(), state)
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

@traitfn function is_cyclic(g::AG::IsDirected) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    state = CycleState(vcolor, zero(T))
    @inbounds for v in vertices(g)
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        !traverse_graph!(g, v, DFS(), state) && return true
    end
    return false
end
