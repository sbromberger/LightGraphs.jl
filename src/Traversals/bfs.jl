import Base.Sort, Base.Sort.Algorithm
import Base:sort!

struct NOOPSortAlg <: Base.Sort.Algorithm end
const NOOPSort = NOOPSortAlg()

sort!(x, ::Integer, ::Integer, ::NOOPSortAlg, ::Base.Sort.Ordering) = x

struct BreadthFirst{T<:Base.Sort.Algorithm} <: TraversalAlgorithm
    neighborfn::Function
    sort_alg::T
end

BreadthFirst(; neighborfn=outneighbors, sort_alg=NOOPSort) = BreadthFirst(neighborfn, sort_alg)

"""
    traverse_graph!(g, s, alg, state)
    traverse_graph!(g, ss, alg, state)

    Traverse a graph `g` starting at vertex `s` / vertices `ss` using algorithm `alg`, maintaining state in [`AbstractTraversalState`](@ref) `state`. Return `true` if traversal finished; `false` if one of the visit functions caused an early termination.
    
"""
function traverse_graph!(
    g::AbstractGraph{U},
    ss::AbstractVector,
    alg::BreadthFirst,
    state::AbstractTraversalState,
    ) where U<:Integer


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

mutable struct DistanceState{T<:Integer} <: AbstractTraversalState
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
function distances(g::AbstractGraph{T}, s, alg::BreadthFirst=BreadthFirst()) where T
    d = fill(typemax(T), nv(g))
    state = DistanceState(d, one(T))
    traverse_graph!(g, s, alg, state)
    return state.distances
end

mutable struct PathState{T} <: AbstractTraversalState
    u::T
    v::T
    exclude_vertices::Vector{T}
    vertices_in_exclude::Bool # set to true if the source or dest are in excludes.
end

@inline function preinitfn!(s::PathState, visited)
    visited[s.exclude_vertices] .= true
    s.vertices_in_exclude = visited[s.u] | visited[s.v]
    return !s.vertices_in_exclude
end
@inline newvisitfn!(s::PathState, u, v) = s.v != v 

"""
    has_path(g::AbstractGraph, u, v, alg=BreadthFirst(); exclude_vertices=Vector())

Return `true` if there is a path from `u` to `v` in `g` (while avoiding vertices in
`exclude_vertices`) or `u == v`. Return false if there is no such path or if `u` or `v`
is in `exclude_vertices`. 


### Performance Notes
sorting `exclude_vertices` prior to calling the function may result in improved performance.
""" 
function has_path(g::AbstractGraph{T}, u::Integer, v::Integer, alg::BreadthFirst=BreadthFirst(); exclude_vertices=Vector{T}()) where {T}
    u == v && return true
    state = PathState(T(u), T(v), T.(exclude_vertices), false)
    result = traverse_graph!(g, u, alg, state)
    # if traverse_graph is false, check the shortcircuit val.
    result && return false
    return !state.vertices_in_exclude
end

