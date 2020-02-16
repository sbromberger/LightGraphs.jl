import Base.Sort, Base.Sort.Algorithm
import Base:sort!

struct NOOPSortAlg <: Base.Sort.Algorithm end
const NOOPSort = NOOPSortAlg()

sort!(x, ::Integer, ::Integer, ::NOOPSortAlg, ::Base.Sort.Ordering) = x

struct BFS{T<:Base.Sort.Algorithm} <: TraversalAlgorithm
    sort_alg::T
end

BFS() = BFS(NOOPSort)

"""
    traverse_graph!(g, s, alg, state, neighborfn=outneighbors)
    traverse_graph!(g, ss, alg, state, neighborfn=outneighbors)

    Traverse a graph `g` starting at vertex `s` / vertices `ss` using algorithm `alg`, maintaining state in [`AbstractTraversalState`](@ref) `state`. Next vertices to be visited are determined by `neighborfn` (default `outneighbors`).
"""
function traverse_graph!(
    g::AbstractGraph{U},
    ss::AbstractVector,
    alg::BFS,
    state::AbstractTraversalState,
    neighborfn::Function=outneighbors
    ) where U<:Integer


    n = nv(g)
    visited = falses(n)
    cur_level = Vector{U}()
    sizehint!(cur_level, n)
    next_level = Vector{U}()
    sizehint!(next_level, n)
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(cur_level, us)
        initfn!(state, us)
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            previsitfn!(state, v)
            @inbounds @simd for i in neighborfn(g, v)
                visitfn!(state, v, i)
                if !visited[i]
                    newvisitfn!(state, v, i)
                    push!(next_level, i)
                    visited[i] = true
                end
            end
            postvisitfn!(state, v)
        end
        postlevelfn!(state)
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level, alg=alg.sort_alg)
    end
    return state
end

mutable struct DistanceState{T<:Integer} <: AbstractTraversalState
    distances::Vector{T}
    n_level::T
end

@inline initfn!(s::DistanceState{T}, u) where T = s.distances[u] = zero(T)
@inline newvisitfn!(s::DistanceState, u, v) = s.distances[v] = s.n_level
@inline postlevelfn!(s::DistanceState{T}) where T = s.n_level += one(T)

"""
    distances(g, s, alg=BFS())
    distances(g, ss, alg=BFS())

Return a vector filled with the geodesic distances of vertices in  `g` from vertex `s` / unique vertices `ss`
using BFS traversal algorithm `alg`.  For vertices in disconnected components the default distance is `typemax(T)`.
"""
function distances(g::AbstractGraph{T}, s, alg::BFS=BFS()) where T
    d = fill(typemax(T), nv(g))
    state = DistanceState(d, one(T))
    traverse_graph!(g, s, alg, state)
    return state.distances
end
