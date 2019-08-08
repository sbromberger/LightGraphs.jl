module ShortestPaths
using SparseArrays: sparse
using LightGraphs
using LightGraphs:AbstractPathState, DijkstraState, BellmanFordState,
      FloydWarshallState, DEsopoPapeState, JohnsonState, AbstractGraph, AbstractEdge
#
# using LightGraphs: dijkstra_shortest_paths, bellman_ford_shortest_paths, floyd_warshall_shortest_paths,
#     desopo_pape_shortest_paths, a_star, johnson_shortest_paths
import Base:convert, getproperty
import LightGraphs: enumerate_paths

using DataStructures:PriorityQueue, enqueue!, dequeue!


struct LGEnvironment
    threaded::Bool
    parallel::Bool
    LGEnvironment() = new(false, false)
end
     
abstract type AbstractGraphResults end
abstract type AbstractGraphAlgorithm end

abstract type ShortestPathResults <: AbstractGraphResults end
abstract type ShortestPathAlgorithm <: AbstractGraphAlgorithm end

include("astar.jl")
include("bellman-ford.jl")
include("bfs.jl")
include("desopo-pape.jl")
include("dijkstra.jl")
include("floyd-warshall.jl")
include("johnson.jl")
include("spfa.jl")


##################
##   Dijkstra   ##
##################


################################
# Shortest Paths via algorithm #
################################
# if we don't pass in distances but specify an algorithm, use weights.
shortest_paths(g::AbstractGraph, s, alg::ShortestPathAlgorithm) =
    shortest_paths(g, s, weights(g), alg)

# If we don't specify an algorithm AND there are no dists, use BFS.
shortest_paths(g::AbstractGraph{T}, s::Integer) where {T<:Integer} = shortest_paths(g, s, BFS())
shortest_paths(g::AbstractGraph{T}, ss::AbstractVector) where {T<:Integer} = shortest_paths(g, ss, BFS())

# Full-formed methods.
"""
    paths(state[, vs])

Given a path state `state` of type `ShortestPathResults`, return a
vector (indexed by vertex) of the paths between the source vertex used to
compute the path state and a single destination vertex, a list of destination
vertices, or the entire graph. For multiple destination vertices, each
path is represented by a vector of vertices on the path between the source and
the destination. Nonexistent paths will be indicated by an empty vector. For
single destinations, the path is represented by a single vector of vertices,
and will be length 0 if the path does not exist.

### Implementation Notes
For Floyd-Warshall path states, please note that the output is a bit different,
since this algorithm calculates all shortest paths for all pairs of vertices:
`enumerate_paths(state)` will return a vector (indexed by source vertex) of
vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)`
will return a vector (indexed by destination vertex) of paths from source `v`
to all other vertices. In addition, `enumerate_paths(state, v, d)` will return
a vector representing the path from vertex `v` to vertex `d`.
"""
function paths(state::ShortestPathResults, vs::AbstractVector{<:Integer})
    parents = state.parents
    T = eltype(parents)

    num_vs = length(vs)
    all_paths = Vector{Vector{T}}(undef, num_vs)
    for i = 1:num_vs
        all_paths[i] = Vector{T}()
        index = T(vs[i])
        if parents[index] != 0 || parents[index] == index
            while parents[index] != 0
                push!(all_paths[i], index)
                index = parents[index]
            end
            push!(all_paths[i], index)
            reverse!(all_paths[i])
        end
    end
    return all_paths
end

paths(state::ShortestPathResults, v::Integer) = paths(state, [v])[1]
paths(state::ShortestPathResults) = paths(state, [1:length(state.parents);])

dists(state::ShortestPathResults, v::Integer) = state.dists[v]
dists(state::ShortestPathResults) = state.dists
export paths, dists, shortest_paths
export Dijkstra, AStar, BellmanFord, FloydWarshall, DEsopoPape, Johnson, SPFA, BFS
export NegativeCycleError

end  # module
