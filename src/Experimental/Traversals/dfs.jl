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
        initfn!(state, us)
    end
    while !isempty(S)
        v = S[end]
        previsitfn!(state, v)
        new_neighbor_found = false
        @inbounds for i in neighborfn(g, v)
            visitfn!(state, v, i)
            if !visited[i]  # find the first unvisited neighbor
                newvisitfn!(state, v, i)
                new_neighbor_found = true
                visited[i] = true
                push!(S, i)
                break
            end
        end
        postvisitfn!(state, v)
        if !new_neighbor_found  # no more new neighbors. Let's go to the next source vertex.
            postlevelfn!(state)
            pop!(S)
        end
    end
    return state
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
end
@inline function visitfn!(s::TopoSortState{T}, u, v) where T 
    # println("visitfn $s, $u, $v")
    s.vcolor[v] == one(T) && error("The input graph contains at least one loop.")
end
@inline function newvisitfn!(s::TopoSortState{T}, u, v) where T 
    # println("newvisitfn $s, $u, $v")
    s.w = v
end

@inline function postvisitfn!(s::TopoSortState{T}, u) where T 
    # println("postvisitfn $s $u")
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
        push!(s.verts, u)
    end
end


@traitfn function topological_sort(g::AG::IsDirected) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    state = TopoSortState(vcolor, verts, zero(T))
    for v in vertices(g)
        # println("new vertex loop $v with state $state")
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        traverse_graph!(g, v, DFS(), state)
    end
    return reverse(state.verts)
end

