module ShortestPaths
using SparseArrays: sparse
using LightGraphs
using LightGraphs.Traversals
using LightGraphs: AbstractGraph, AbstractEdge
using LightGraphs.SimpleGraphs: AbstractSimpleGraph
using DataStructures:PriorityQueue, enqueue!, dequeue!

import LightGraphs.Traversals: initfn!, previsitfn!, newvisitfn!, visitfn!, postvisitfn!, postlevelfn!

# TODO: figure out how we keep environmental params.
# struct LGEnvironment
#     threaded::Bool
#     parallel::Bool
#     LGEnvironment() = new(false, false)
# end
     
abstract type AbstractGraphResult end
abstract type AbstractGraphAlgorithm end

"""
    ShortestPathResult <: AbstractGraphResult

Concrete subtypes of `ShortestPathResult` contain the
results of a shortest-path calculation using a specific
[`ShortestPathAlgorithm`](@ref).

In general, the fields in these structs should not be
accessed directly; use the [`dists`](@ref) and
[`paths`](@ref) functions to obtain the results of the
calculation.
"""
abstract type ShortestPathResult <: AbstractGraphResult end


"""
    ShortestPathAlgorithm <: AbstractGraphAlgorithm

Concrete subtypes of `ShortestPathAlgorithm` are used to specify
the type of shortest path calculation used by [`shortest_paths`](@ref).
Some concrete subtypes (most notably [`Dijkstra`](@ref) have fields
that specify algorithm parameters.

See [`AStar`](@ref), [`BellmanFord`](@ref), [`BFS`](@ref),
[`DEspopoPape`](@ref), [`Dijkstra`](@ref), [`FloydWarshall`](@ref),
[`Johnson`](@ref), and [`SPFA`](@ref) for specific requirements and
usage details.
"""
abstract type ShortestPathAlgorithm <: AbstractGraphAlgorithm end

include("astar.jl")
include("bellman-ford.jl")
include("bfs.jl")
include("desopo-pape.jl")
include("dijkstra.jl")
include("floyd-warshall.jl")
include("johnson.jl")
include("spfa.jl")


################################
# Shortest Paths via algorithm #
################################
# if we don't pass in distances but specify an algorithm, use weights.
"""
    shortest_paths(g, s, distmx, alg)
    shortest_paths(g, s, t, alg)
    shortest_paths(g, s, alg)
    shortest_paths(g, s)
    shortest_paths(g)

Return a `ShortestPathResult` that allows construction of the shortest path
between sets of vertices in graph `g`. Depending on the algorithm specified,
other information may be required: (e.g., a distance matrix `distmx`, and/or
a target vertex `t`). Some algorithms will accept multiple source vertices
`s`; algorithms that do not accept any source vertex `s` produce all-pairs
shortest paths. 

See `ShortestPathAlgorithm` for more details on the algorithm specifications.

### Implementation Notes
The elements of `distmx` may be of any type that has a [Total Ordering](https://en.m.wikipedia.org/wiki/Total_order)
and valid comparator, `zero` and `typemax` functions. Concretely, this means that
distance matrices containing complex numbers are invalid.

### Examples
```
g = path_graph(4)
w = zeros(4, 4)
for i in 1:3
    w[i, i+1] = 1.0
    w[i+1, i] = 1.0
end

s1 = shortest_paths(g)                   # `alg` defaults to `FloydWarshall`
s2 = shortest_paths(g, 1)                # `alg` defaults to `BFS`
s3 = shortest_paths(g, 1, w)             # `alg` defaults to `Dijkstra`
s4 = shortest_paths(g, 1, BellmanFord())
s5 = shortest_paths(g, 1, w, DEsopoPape())
```
"""
shortest_paths(g::AbstractGraph, s, alg::ShortestPathAlgorithm) =
    shortest_paths(g, s, weights(g), alg)

# If we don't specify an algorithm AND there are no dists, use BFS.
shortest_paths(g::AbstractGraph{T}, s::Integer) where {T<:Integer} = shortest_paths(g, s, BFS())
shortest_paths(g::AbstractGraph{T}, ss::AbstractVector) where {T<:Integer} = shortest_paths(g, ss, BFS())

# Full-formed methods.
"""
    paths(state[, v])
    paths(state[, vs])
    paths(state[, v, d]))

Given the output of a [`shortest_paths`](@ref) calculation of type
[`ShortestPathResult`](@ref), return a vector (indexed by vertex)
of the paths between the source vertex used to compute the shortest path
and a single destination vertex `v`, a vector of destination vertices `vs`,
or the entire graph.

For multiple destination vertices, each path is represented by a vector of
vertices on the path between the source and the destination. Nonexistent
paths will be indicated by an empty vector. For single destinations, the
path is represented by a single vector of vertices, and will be length 0
if the path does not exist.

For [`ShortestPathAlgorithm`](@ref)s that compute all shortest paths for all
pairs of vertices, `paths(state)` will return a vector (indexed by source
vertex) of vectors (indexed by destination vertex) of paths. `paths(state, v)`
will return a vector (indexed by destination vertex) of paths from source `v`
to all other vertices. In addition, `paths(state, v, d)` will return a vector
representing the path from vertex `v` to vertex `d`.
"""
function paths(state::ShortestPathResult, vs::AbstractVector{<:Integer})
    parents = state.parents
    T = eltype(parents)

    num_vs = length(vs)
    all_paths = Vector{Vector{T}}(undef, num_vs)
    for i = 1:num_vs
        all_paths[i] = Vector{T}()
        index = T(vs[i])
        if parents[index] != 0 || parents[index] == index
            while parents[index] != 0
                pushfirst!(all_paths[i], index)
                index = parents[index]
            end
            pushfirst!(all_paths[i], index)
        end
    end
    return all_paths
end

paths(state::ShortestPathResult, v::Integer) = paths(state, [v])[1]
paths(state::ShortestPathResult) = paths(state, [1:length(state.parents);])

"""
    dists(state[, v])

Given the output of a [`shortest_paths`](@ref) calculation of type
[`ShortestPathResult`](@ref), return a vector (indexed by vertex)
of the distances between the source vertex used to compute the
shortest path and a single destination vertex `v` or the entire graph.

For [`ShortestPathAlgorithm`](@ref)s that compute all-pairs shortest
paths, `dists(state)` will return a matrix (indexed by source and destination
vertices) of distances.
"""
dists(state::ShortestPathResult, v::Integer) = state.dists[v]
dists(state::ShortestPathResult) = state.dists

"""
    has_negative_weight_cycle(g[, distmx=weights(g), alg=BellmanFord()])

Given a graph `g`, an optional distance matrix `distmx`, and an optional
algorithm `alg` (one of [`BellmanFord`](@ref) or [`SPFA`](@ref)), return
`true` if any cycle detected in the graph has a negative weight.
# Examples

```jldoctest
julia> g = complete_graph(3);

julia> d = [1 -3 1; -3 1 1; 1 1 1];

julia> has_negative_weight_cycle(g, d)
true

julia> g = complete_graph(4);

julia> d = [1 1 -1 1; 1 1 -1 1; 1 1 1 1; 1 1 1 1];

julia> has_negative_weight_cycle(g, d, SPFA())
false
```
"""
has_negative_weight_cycle(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) = has_negative_weight_cycle(g, distmx, BellmanFord())
has_negative_weight_cycle(g::AbstractSimpleGraph) = false

export ShortestPathAlgorithm
export paths, dists, shortest_paths, has_negative_weight_cycle
export Dijkstra, AStar, BellmanFord, FloydWarshall, DEsopoPape, Johnson, SPFA, BFS
export NegativeCycleError

end  # module
