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
    S = Vector{Tuple{U,U}}()
    sizehint!(S, length(ss))
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(S, (us,0))
        initfn!(state, us) || return false
    end

    ptr = one(U)

    while !isempty(S)
        v,_ = S[end]
        previsitfn!(state, v) || return false

        my_neighbours=neighborfn(g, v)
        @inbounds while ptr<=length(my_neighbours)
            i = my_neighbours[ptr]
            visitfn!(state, v, i) || return false
            if !visited[i]  # find the first unvisited neighbor
                newvisitfn!(state, v, i) || return false

                visited[i] = true
                push!(S, (i,ptr+1))
                break
            end
            ptr+=1
        end


        postvisitfn!(state, v) || return false

 #= if ptr > length(my_neighbours)
 then, we have finched all childern of the node,
  and the next time we pop from the stack we will be in the parent of the current
  node, then we would like to continue from we stoped,
else, we have found an new unvisited child, so we will make ptr = 1


=#


        if ptr > length(my_neighbours)
            postlevelfn!(state) || return false
            _ , ptr =pop!(S)
        else
            ptr = 1 # we will enter new node new node
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
