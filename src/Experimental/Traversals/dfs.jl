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
    parents = zeros(U, n)
    S = Vector{U}()
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(S, us)
        initfn!(state, us) || return false
    end

    while !isempty(S)
        v = S[end]
        if parents[v] != zero(U)
            newvisitfn!(state, visited, parents[v], v) || return false
        end
        previsitfn!(state, visited, v) || return false

        @inbounds for i in neighbors(g, v)
            visitfn!(state, visited, v, i) || return false
            if !visited[i]
                visited[i] = true
                parents[i] = v
                push!(S, i)
            end
        end

        while (!isempty(S) && S[end] == v) 
            postvisitfn!(state, visited, v) || return false
            pop!(S)
            v = parents[v]
        end

        # postlevelfn!(state, visited, v)
    end
    return true
end

mutable struct TopoSortState{T<:Integer} <: AbstractTraversalState
    vcolor::Vector{UInt8}
    verts :: Vector{T}
    w::T
end

# 1 = visited, currently in stack
# 2 = visited, done / not in stack
@inline function previsitfn!(s::TopoSortState{T}, u) where T
    s.vcolor[u] = one(T)
    return true
end
@inline function visitfn!(s::TopoSortState{T}, u, v) where T 
    return s.vcolor[v] != one(T)
end
@inline function postvisitfn!(s::TopoSortState{T}, u) where T 
    s.vcolor[u] = T(2)
    push!(s.verts, u)
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
    s.vcolor[u] = one(T)
    return true
end
@inline function visitfn!(s::CycleState{T}, u, v) where T 
    return s.vcolor[v] != one(T)
end
@inline function postvisitfn!(s::CycleState{T}, u) where T
    s.vcolor[u] = T(2)
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
