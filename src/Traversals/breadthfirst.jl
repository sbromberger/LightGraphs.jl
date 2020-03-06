import Base.Sort, Base.Sort.Algorithm
import Base:sort!

struct NOOPSortAlg <: Base.Sort.Algorithm end
const NOOPSort = NOOPSortAlg()

sort!(x, ::Integer, ::Integer, ::NOOPSortAlg, ::Base.Sort.Ordering) = x

struct BreadthFirst{F<:Function, T<:Base.Sort.Algorithm} <: TraversalAlgorithm
    neighborfn::F
    sort_alg::T
end

BreadthFirst(; neighborfn=outneighbors, sort_alg=NOOPSort) = BreadthFirst(neighborfn, sort_alg)

"""
    traverse_graph!(g, s, alg, state)
    traverse_graph!(g, ss, alg, state)

    Traverse a graph `g` starting at vertex `s` / vertices `ss` using algorithm `alg`, maintaining state in [`TraversalState`](@ref) `state`. Return `true` if traversal finished; `false` if one of the visit functions caused an early termination.
    
"""
function traverse_graph!(
    g::AbstractGraph{U},
    ss::AbstractVector,
    alg::BreadthFirst,
    state::TraversalState) where {U<:Integer}


    n = nv(g)
    visited = falses(n)
    cur_level = Vector{U}()
    sizehint!(cur_level, n)
    next_level = Vector{U}()
    sizehint!(next_level, n)
    preinitfn!(state, visited) || return false
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(cur_level, us)
        initfn!(state, us) || return false
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            previsitfn!(state, v) || return false
            @inbounds @simd for i in alg.neighborfn(g, v)
                visitfn!(state, v, i) || return false
                if !visited[i]
                    newvisitfn!(state, v, i) || return false
                    push!(next_level, i)
                    visited[i] = true
                end
            end
            postvisitfn!(state, v) || return false
        end
        postlevelfn!(state) || return false
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level, alg=alg.sort_alg)
    end
    return true
end

mutable struct DistanceState{T<:Integer} <: TraversalState
    distances::Vector{T}
    n_level::T
end

@inline function initfn!(s::DistanceState{T}, u) where T 
    s.distances[u] = zero(T)
    return true
end
@inline function newvisitfn!(s::DistanceState, u, v) 
    s.distances[v] = s.n_level
    return true
end
@inline function postlevelfn!(s::DistanceState{T}) where T
    s.n_level += one(T)
    return true
end

"""
    distances(g, s, alg=BreadthFirst())
    distances(g, ss, alg=BreadthFirst())

Return a vector filled with the geodesic distances of vertices in  `g` from vertex `s` / unique vertices `ss`
using BreadthFirst traversal algorithm `alg`.  For vertices in disconnected components the default distance is `typemax(T)`.
"""
distances(g::AbstractGraph{T}, s, alg::BreadthFirst=BreadthFirst()) where T =
    distances!(g, s, alg, DistanceState(fill(typemax(T), nv(g)), one(T)))
