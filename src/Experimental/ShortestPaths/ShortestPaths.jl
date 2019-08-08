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
include("floyd-warshall.jl")
include("johnson.jl")
include("spfa.jl")



##################
##D'Esposo-Pape ##
##################
struct DEsopoPape <: ShortestPathAlgorithm end
struct DEsopoPapeResults{T<:Real, U<:Integer} <: ShortestPathResults
    parents::Vector{U}
    dists::Vector{T}
end

convert(::Type{AbstractPathState}, spr::DEsopoPapeResults) = convert(DEsopoPapeState, spr)
convert(::Type{<:DEsopoPapeResults}, s::DEsopoPapeState) =
    DEsopoPapeResults(s.parents, s.dists)
convert(::Type{<:DEsopoPapeState}, spr::DEsopoPapeResults) = 
    DEsopoPapeState(spr.parents, spr.dists)

DEsopoPapeResults(s::DEsopoPapeState) = convert(DEsopoPapeResults, s)
DEsopoPapeState(spr::DEsopoPapeResults) = convert(DEsopoPapeState, spr)

##################
##   Dijkstra   ##
##################
struct DijkstraResults{T<:Real, U<:Integer}  <: ShortestPathResults
    parents::Vector{U}
    dists::Vector{T}
    predecessors::Vector{Vector{U}}
    pathcounts::Vector{UInt64}
    closest_vertices::Vector{U}
end

convert(::Type{AbstractPathState}, spr::DijkstraResults) = convert(DijkstraState, spr)
convert(::Type{<:DijkstraResults}, s::DijkstraState) =
    DijkstraResults(s.parents, s.dists, s.predecessors, s.pathcounts, s.closest_vertices)

convert(::Type{<:DijkstraState}, spr::DijkstraResults) =
    DijkstraState(spr.parents, spr.dists, spr.predecessors, spr.pathcounts, spr.closest_vertices)

# These constructors do not copy. They probably should, but you shouldn't be changing the values in any case.
# Can we just document that it's undefined behavior to change any element of a SPR?
DijkstraResults(s::DijkstraState) = convert(DijkstraResults, s)
DijkstraState(spr::DijkstraResults) = convert(DijkstraState, spr)

struct Dijkstra <: ShortestPathAlgorithm
    all_paths::Bool
    track_vertices::Bool
end

Dijkstra(;all_paths=false, track_vertices=false) = Dijkstra(all_paths, track_vertices)



################################
# Shortest Paths via algorithm #
################################
# if we don't pass in distances but specify an algorithm, use weights.
shortest_paths(g::AbstractGraph, s, alg::ShortestPathAlgorithm) =
    shortest_paths(g, s, weights(g), alg)

# If we don't specify an algorithm, use dijkstra.
shortest_paths(g::AbstractGraph{T}, s, distmx::AbstractMatrix) where {T<:Integer} =
    shortest_paths(g, s, distmx, Dijkstra())

# If we don't specify an algorithm AND there are no dists, use BFS.
shortest_paths(g::AbstractGraph{T}, s::Integer) where {T<:Integer} = shortest_paths(g, s, BFS())
shortest_paths(g::AbstractGraph{T}, ss::AbstractVector) where {T<:Integer} = shortest_paths(g, ss, BFS())

# Full-formed methods.
shortest_paths(g::AbstractGraph, ss::AbstractVector, distmx::AbstractMatrix, alg::Dijkstra) =
    DijkstraResults(dijkstra_shortest_paths(g, ss, distmx, allpaths=alg.all_paths, trackvertices=alg.track_vertices))
shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix, alg::Dijkstra) = shortest_paths(g, [s], distmx, alg)
    
shortest_paths(g::AbstractGraph, ss, distmx::AbstractMatrix, alg::BellmanFord) =
    BellmanFordResults(bellman_ford_shortest_paths(g, ss, distmx))

shortest_paths(g::AbstractGraph, s::Integer, t::Integer, distmx::AbstractMatrix, alg::AStar{F}) where {F<:Function} =
    AStarResults(a_star(g, s, t, distmx, alg.heuristic))

shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix, alg::DEsopoPape) =
    DEsopoPapeResults(desopo_pape_shortest_paths(g, s, distmx))

shortest_paths(g::AbstractGraph, s::Integer, alg::DEsopoPape) = shortest_paths(g, s, weights(g), alg)

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
