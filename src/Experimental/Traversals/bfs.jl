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
    ss::AbstractVector{U},
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
        visited[s] = true
        push!(cur_level, s)
        initfn!(state, s)
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            previsitfn!(state, v)
            @inbounds @simd for i in neighborfn(g, v)
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

traverse_graph!(g, s::Integer, alg, state, neighborfn) = traverse_graph!(g, [s], alg, state, neighborfn)
traverse_graph!(g, s::Integer, alg, state) = traverse_graph!(g, [s], alg, state)

struct VisitState{T<:Integer} <: AbstractTraversalState
    visited::Vector{T}
end

@inline initfn!(s::VisitState, u) = push!(s.visited, u)
@inline newvisitfn!(s::VisitState, u, v) = push!(s.visited, v)

"""
    visited_vertices(g, s, alg)
    visited_vertices(g, ss, alg)

Return a vector representing the vertices of `g` visited in order by [`TraversalAlgorithm`](@ref) `alg`
starting at vertex `s` (vertices `ss`).
"""
function visited_vertices(
    g::AbstractGraph{U},
    ss::AbstractVector{U},
    alg::TraversalAlgorithm
    ) where U<:Integer

    v = Vector{U}()
    sizehint!(v, nv(g))  # actually just the largest connected component, but we'll use this.
    s = VisitState(v)
    traverse_graph!(g, ss, alg, s)

    return state.visited
end

"""
    parents(g, s, alg, dir=:out)

Return a vector of parent vertices indexed by vertex using [`TraversalAlgorithm`](@ref) `alg` starting with
vertex `s`. If `dir` is specified, use the corresponding edge direction (`:in` and `:out` are acceptable
values).

### Performance
This implementation is designed to perform well on large graphs. There are
implementations which are marginally faster in practice for smaller graphs,
but the performance improvements using this implementation on large graphs
can be significant.
"""
parents(g::AbstractGraph, s::Integer, alg::TraversalAlgorithm, dir = :out) =
    (dir == :out) ? parents(g, s, alg, outneighbors) : parents(g, s, alg, inneighbors)

mutable struct ParentState{T<:Integer} <: AbstractTraversalState
    parents::Vector{T}
end

@inline newvisitfn!(s::ParentState, u, v) = s.parents[v] = u
function parents(g::AbstractGraph{T}, s::Integer, alg::TraversalAlgorithm, neighborfn::Function) where T
    parents = zeros(T, nv(g))
    state = ParentState(parents)

    traverse_graph!(g, s, alg, state, neighborfn)
    return state.parents
end

mutable struct DistanceState{T<:Integer} <: AbstractTraversalState
    distances::Vector{T}
    n_level::T
end

@inline initfn!(s::GDistanceState{T}, u) where T = s.distances[u] = zero(T)
@inline newvisitfn!(s::GDistanceState, u, v) = s.distances[v] = s.n_level
@inline postlevelfn!(s::GDistanceState{T}) where T = s.n_level += one(T)

"""
    distances(g, s; sort_alg=QuickSort)
    distances(g, ss; sort_alg=QuickSort)

Return a vector filled with the geodesic distances of vertices in  `g` from vertex
`s` / unique vertices `ss`. For vertices in disconnected components the default
distance is `typemax(T)`.

An optional sorting algorithm may be specified (see Performance section).

### Performance
`gdistances` uses `QuickSort` internally for its default sorting algorithm, since it performs
the best of the algorithms built into Julia Base. However, passing a `RadixSort` (available via
[SortingAlgorithms.jl](https://github.com/JuliaCollections/SortingAlgorithms.jl)) will provide
significant performance improvements on larger graphs.
"""
function distances(g::AbstractGraph{T}, s; sort_alg=QuickSort) where T
    d = fill(typemax(T), nv(g))
    state = DistanceState(d, 1)
    traverse_graph!(g, s, BFS(sort_alg), state)
    return state.distances
end


    


