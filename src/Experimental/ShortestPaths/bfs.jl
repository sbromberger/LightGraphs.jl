import Base.Sort, Base.Sort.Algorithm
import Base:sort!
struct NOOPSortAlg <: Base.Sort.Algorithm end
const NOOPSort = NOOPSortAlg()

sort!(x, ::Integer, ::Integer, ::ShortestPaths.NOOPSortAlg, ::Base.Sort.Ordering) = x

"""
    struct BFS <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [Breadth-First Search algorithm](https://en.m.wikipedia.org/wiki/Breadth-first_search).

An optional sorting algorithm may be specified (default = no sorting).
Sorting helps maintain cache locality and will improve performance on
very large graphs; for normal use, sorting will incur a performance
penalty.

`BFS` is the default algorithm used when a source is specified
but no distance matrix is specified.

### Implementation Notes
`BFS` supports the following shortest-path functionality:
- (optional) multiple sources
- all destinations
"""
struct BFS{T<:Base.Sort.Algorithm} <: ShortestPathAlgorithm
    sort_alg::T
end

BFS() = BFS(NOOPSort)

struct BFSResult{U<:Integer} <: ShortestPathResult
    parents::Vector{U}
    dists::Vector{U}
end

function shortest_paths(
    g::AbstractGraph{U},
    ss::AbstractVector{U},
    alg::BFS,
    ) where U<:Integer


    n = nv(g)
    dists = fill(typemax(U), n)
    parents = zeros(U, n)
    visited = falses(n)
    n_level = one(U)
    cur_level = Vector{U}()
    sizehint!(cur_level, n)
    next_level = Vector{U}()
    sizehint!(next_level, n)
    @inbounds for s in ss
        dists[s] = zero(U)
        visited[s] = true
        push!(cur_level, s)
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            @inbounds for i in outneighbors(g, v)
                if !visited[i]
                    push!(next_level, i)
                    dists[i] = n_level
                    parents[i] = v
                    visited[i] = true
                end
            end
        end
        n_level += one(U)
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level, alg=alg.sort_alg)
    end
    return BFSResult(parents, dists)
end

shortest_paths(g::AbstractGraph{U}, ss::AbstractVector{<:Integer}, alg::BFS) where {U<:Integer} = shortest_paths(g, U.(ss), alg)
shortest_paths(g::AbstractGraph{U}, s::Integer, alg::BFS) where {U<:Integer} = shortest_paths(g, Vector{U}([s]), alg)
