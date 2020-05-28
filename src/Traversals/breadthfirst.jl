import Base.Sort, Base.Sort.Algorithm
import Base:sort!

struct NOOPSortAlg <: Base.Sort.Algorithm end
const NOOPSort = NOOPSortAlg()

sort!(x, ::Integer, ::Integer, ::NOOPSortAlg, ::Base.Sort.Ordering) = x

struct BreadthFirst{F<:Function, T<:Base.Sort.Algorithm} <: TraversalAlgorithm
    neighborfn::F
    sort_alg::T
end

BreadthFirst(; neighborfn=outneighbors, sort_alg=QuickSort) = BreadthFirst(neighborfn, sort_alg)

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
    state::TraversalState) where {U<:Integer}


    n = nv(g)
    visited = falses(n)
    cur_level = Vector{U}()
    sizehint!(cur_level, n)
    next_level = Vector{U}()
    sizehint!(next_level, n)
    is_successful(preinitfn!(state, visited)) || return false
    @inbounds for s in ss
        us = U(s)
        visited[us] = true
        push!(cur_level, us)
        is_successful(initfn!(state, us)) || return false
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            is_successful(previsitfn!(state, v)) || return false
            @inbounds for i in alg.neighborfn(g, v)
                x = visitfn!(state, v, i)
                x ==  VTERMINATE && return false # terminate bfs
                x == VSKIP && continue  # skip to next neighbor
                x == VFAIL && break # stop exploring curr vertex's neighbors
                if !visited[i]
                    # newvisitfn! return values have same effect as visitfn! but only for
                    # newly discovered vertices
                    x = newvisitfn!(state, v, i)
                    x ==  VTERMINATE && return false
                    x == VSKIP && continue
                    x == VFAIL && break
                    push!(next_level, i)
                    visited[i] = true
                else
                    # revisitfn! return values have same effect as visitfn! but only for
                    # rediscovered vertices
                    x = revisitfn!(state, v, i)
                    x ==  VTERMINATE && return false
                    x == VSKIP && continue
                    x == VFAIL && break
                end
            end
            is_successful(postvisitfn!(state, v)) || return false
        end
        is_successful(postlevelfn!(state)) || return false
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level, alg=alg.sort_alg)
    end
    return true
end

