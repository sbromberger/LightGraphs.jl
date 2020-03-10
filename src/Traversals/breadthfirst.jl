import Base.Sort, Base.Sort.Algorithm
import Base: sort!

struct NOOPSortAlg <: Base.Sort.Algorithm end
const NOOPSort = NOOPSortAlg()

sort!(x, ::Integer, ::Integer, ::NOOPSortAlg, ::Base.Sort.Ordering) = x

struct BreadthFirst{F <: Function, T <: Base.Sort.Algorithm} <: TraversalAlgorithm
    neighborfn::F
    sort_alg::T
end

BreadthFirst(; neighborfn = outneighbors, sort_alg = NOOPSort) = BreadthFirst(neighborfn, sort_alg)

"""
    traverse_graph!(g, ss, alg, state)

Traverse a graph `g` starting at vertex/vertices `ss` using algorithm `alg`, maintaining state in
[`TraversalState`](@ref) `state`. Return `true` if traversal finished; `false` if one of the visit
functions caused an early termination.
"""
function traverse_graph!(
    g::AbstractGraph{U},
    ss,
    alg::BreadthFirst,
    state::TraversalState,
) where {U <: Integer}

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
        sort!(cur_level, alg = alg.sort_alg)
    end
    return true
end
