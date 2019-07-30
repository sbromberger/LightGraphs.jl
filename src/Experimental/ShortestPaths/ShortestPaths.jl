module ShortestPaths
using LightGraphs:AbstractPathState, DijkstraState, BellmanFordState,
    FloydWarshallState, DEsopoPapeState, AbstractGraph, AbstractEdge, weights

using LightGraphs: dijkstra_shortest_paths, bellman_ford_shortest_paths, floyd_warshall_shortest_paths,
    desopo_pape_shortest_paths, a_star
import Base:convert, getproperty
import LightGraphs: enumerate_paths

const paths = enumerate_paths

struct LGEnvironment
    threaded::Bool
    parallel::Bool
    LGEnvironment() = new(false, false)
end
     
abstract type AbstractGraphResults end
abstract type AbstractGraphAlgorithm end

abstract type ShortestPathResults <: AbstractGraphResults end
abstract type ShortestPathAlgorithm <: AbstractGraphAlgorithm end

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

    Dijkstra() = new(false, false)
end


##################
##    A-Star    ##
##################
struct AStarResults{E<:AbstractEdge} <: ShortestPathResults
    path::Vector{E}
end
# for completeness and consistency.
struct AStarState{E<:AbstractEdge} <: AbstractPathState
    path::Vector{E}
end

function paths(s::AStarState)
    T = eltype(eltype(s.path))
    n = length(s.path)
    n == 0 && return Vector{T}()
    p = Vector{T}(undef, n+1)
    p[1] = src(s.path[1])
    p[end] = dst(s.path[end])
    for i in 2:n
        p[i] = src(s.path[i])
    end
    return p
end

convert(::Type{AbstractPathState}, spr::AStarResults) = convert(AStarState, spr)
convert(::Type{<:AStarResults}, s::AStarState) = AStarResults(s.path)

convert(::Type{<:AStarState}, spr::AStarResults) = AStarState(spr.path)

struct AStar{F<:Function} <: ShortestPathAlgorithm
    heuristic::F
end
AStarResults(s::AStarState) = convert(AStarResults, s)
AStarState(spr::AStarResults) = convert(AStarState, spr)

AStar(T::Type{<:Real}=Float64) = AStar(n -> zero(T))


##################
## Bellman-Ford ##
##################
struct BellmanFord <: ShortestPathAlgorithm end
struct BellmanFordResults{T<:Real, U<:Integer} <: ShortestPathResults
    parents::Vector{U}
    dists::Vector{T}
end

convert(::Type{AbstractPathState}, spr::BellmanFordResults) = convert(BellmanFordState, spr)
convert(::Type{<:BellmanFordResults}, s::BellmanFordState) =
    BellmanFordResults(s.parents, s.dists)

convert(::Type{<:BellmanFordState}, spr::BellmanFordResults) =
    BellmanFordState(spr.parents, spr.dists)



BellmanFordResults(s::BellmanFordState) = convert(BellmanFordResults, s)
BellmanFordState(spr::BellmanFordResults) = convert(BellmanFordState, spr)



##################
##Floyd-Warshall##
##################

struct FloydWarshall <: ShortestPathAlgorithm end
struct FloydWarshallResults{T<:Real, U<:Integer} <: ShortestPathResults
    parents::Matrix{U}
    dists::Matrix{T}
end

convert(::Type{AbstractPathState}, spr::FloydWarshallResults) = convert(FloydWarshallState, spr)
convert(::Type{<:FloydWarshallResults}, s::FloydWarshallState) =
    FloydWarshallResults(s.parents, s.dists)
convert(::Type{<:FloydWarshallState}, spr::FloydWarshallResults) = 
    FloydWarshallState(spr.dists, spr.parents) # note - FWState is reversed from the others. Yuck.

FloydWarshallResults(s::FloydWarshallState) = convert(FloydWarshallResults, s)
FloydWarshallState(spr::FloydWarshallResults) = convert(FloydWarshallState, spr)

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
# if we don't pass in distances, use weights.
shortest_paths(g::AbstractGraph, ss::Vector{T}, alg::ShortestPathAlgorithm) where {T<:Integer} =
    shortest_paths(g, ss, weights(g), alg)

# for A*, if we don't pass in distances...
shortest_paths(g::AbstractGraph, s::Integer, t::Integer, alg::AStar) =
    shortest_paths(g, s, t, weights(g), alg)

# If we don't specify an algorithm, use dijkstra.
shortest_paths(g::AbstractGraph, s::Vector{T}, distmx::AbstractMatrix=weights(g)) where {T<:Integer} =
shortest_paths(g, s, distmx, Dijkstra())

# If we don't specify an algorithm and source is a scalar.
shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix=weights(g)) =
    shortest_paths(g, [s], distmx)

shortest_paths(g::AbstractGraph, s::Integer, alg::ShortestPathAlgorithm) = 
    shortest_paths(g, [s], alg)

# If we don't specify an algorithm AND there's no source, use Floyd-Warshall.
shortest_paths(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    shortest_paths(g, distmx, FloydWarshall())

# Full-formed methods.
shortest_paths(g::AbstractGraph, ss, distmx, alg::Dijkstra) =
    DijkstraResults(dijkstra_shortest_paths(g, ss, distmx, allpaths=alg.all_paths, trackvertices=alg.track_vertices))
    
shortest_paths(g::AbstractGraph, ss, distmx, alg::BellmanFord) =
    BellmanFordResults(bellman_ford_shortest_paths(g, ss, distmx))

shortest_paths(g::AbstractGraph, s::Integer, t::Integer, distmx, alg::AStar{F}) where {F<:Function} =
    AStarResults(a_star(g, s, t, distmx, alg.heuristic))

shortest_paths(g::AbstractGraph, distmx, alg::FloydWarshall) =
    FloydWarshallResults(floyd_warshall_shortest_paths(g, distmx))

shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix, alg::DEsopoPape) =
    DEsopoPapeResults(desopo_pape_shortest_paths(g, s, distmx))

shortest_paths(g::AbstractGraph, s::Integer, alg::DEsopoPape) =
DEsopoPapeResults(desopo_pape_shortest_paths(g, s, weights(g)))

paths(s::ShortestPathResults) = paths(convert(AbstractPathState, s))
    
#
# We might not want this.
# function getproperty(spr::ShortestPathResults, sym::Symbol)
#    if sym === :paths
#        return paths(convert(AbstractPathState, spr))
#    else # fallback to getfield
#        return getfield(spr, sym)
#    end
# end
#
#

export paths, shortest_paths
export Dijkstra, AStar, BellmanFord, FloydWarshall, DEsopoPape

end  # module
