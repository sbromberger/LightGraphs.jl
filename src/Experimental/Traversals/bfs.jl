import Base.Sort, Base.Sort.Algorithm
import Base:sort!

struct NOOPSortAlg <: Base.Sort.Algorithm end
const NOOPSort = NOOPSortAlg()

sort!(x, ::Integer, ::Integer, ::NOOPSortAlg, ::Base.Sort.Ordering) = x

struct BFS{T<:Base.Sort.Algorithm} <: AbstractTraversalAlgorithm
    sort_alg::T
end

BFS() = BFS(NOOPSort)

"""
    traverse_graph(g, s, alg, state)
    traverse_graph(g, ss, alg, state)

    Traverse a graph `g` starting at vertex `s` / vertices `ss` using algorithm `alg`, maintaining state in [`AbstractTraversalState`](@ref) `state`.
"""
function traverse_graph(
    g::AbstractGraph{U},
    ss::AbstractVector{U},
    alg::BFS,
    state::AbstractTraversalState=DefaultTraversalState(),
    ) where U<:Integer


    n = nv(g)
    visited = falses(n)
    cur_level = Vector{U}()
    sizehint!(cur_level, n)
    next_level = Vector{U}()
    sizehint!(next_level, n)
    @inbounds for s in ss
        visited[s] = true
        push!(cur_level, s)
        initfn!(state, s)
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            previsitfn!(state, v)
            @inbounds @simd for i in outneighbors(g, v)
                if !visited[i]
                    newvisitfn!(state, v, i)
                    push!(next_level, i)
                    visited[i] = true
                end
                visitfn!(state, v, i)
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

traverse_graph(g, s::Integer, alg, state) = traverse_graph(g, [s], alg, state)

struct VisitState{T<:Integer} <: AbstractTraversalState
    visited::Vector{T}
end

@inline initfn!(s::VisitState, u) = push!(s.visited, u)
@inline newvisitfn!(s::VisitState, u, v) = push!(s.visited, v)

function visited_vertices(
    g::AbstractGraph{U},
    ss::AbstractVector{U},
    alg::AbstractTraversalAlgorithm
    ) where U<:Integer

    v = Vector{U}()
    sizehint!(v, nv(g))  # actually just the largest connected component, but we'll use this.
    s = VisitState(v)
    traverse_graph(g, ss, alg, s)

    return state.visited
end
