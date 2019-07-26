using LightGraphs:AbstractPathState, DijkstraState, BellmanFordState
import Base:convert, getproperty
struct LGEnvironment
    threaded::Bool
    parallel::Bool
    LGEnvironment() = new(false, false)
end
     
abstract type AbstractGraphResults end
abstract type ShortestPathResults <: AbstractGraphResults end
struct DijkstraShortestPathResults{T <: Real, U <: Integer}  <: ShortestPathResults
    parents::Vector{U}
    dists::Vector{T}
    predecessors::Vector{Vector{U}}
    pathcounts::Vector{UInt64}
    closest_vertices::Vector{U}
end

struct BellmanFordShortestPathResults{T<:Real, U<:Integer} <: ShortestPathResults
    parents::Vector{U}
    dists::Vector{T}
end

function getproperty(spr::ShortestPathResults, sym::Symbol)
   if sym === :paths
       return enumerate_paths(convert(AbstractPathState, spr))
   else # fallback to getfield
       return getfield(spr, sym)
   end
end

convert(::Type{AbstractPathState}, spr::DijkstraShortestPathResults) = convert(DijkstraState, spr)
convert(::Type{<:DijkstraShortestPathResults}, s::DijkstraState) =
    DijkstraShortestPathResults(s.parents, s.dists, s.predecessors, s.pathcounts, s.closest_vertices)

convert(::Type{<:DijkstraState}, spr::DijkstraShortestPathResults) =
    DijkstraState(spr.parents, spr.dists, spr.predecessors, spr.pathcounts, spr.closest_vertices)

convert(::Type{AbstractPathState}, spr::BellmanFordShortestPathResults) = convert(BellmanFordState, spr)
convert(::Type{<:BellmanFordShortestPathResults}, s::BellmanFordState) =
    BellmanFordShortestPathResults(s.parents, s.dists)

convert(::Type{<:BellmanFordState}, spr::BellmanFordShortestPathResults) =
    BellmanFordState(spr.parents, spr.dists)


DijkstraShortestPathResults(s::DijkstraState) = convert(DijkstraShortestPathResults, s)
DijkstraState(spr::DijkstraShortestPathResults) = convert(DijkstraState, spr)

BellmanFordShortestPathResults(s::BellmanFordState) = convert(BellmanFordShortestPathResults, s)
BellmanFordState(spr::BellmanFordShortestPathResults) = convert(BellmanFordState, spr)

abstract type AbstractGraphAlgorithm end
abstract type ShortestPathAlgorithm <: AbstractGraphAlgorithm end
struct DijkstraShortestPathAlgorithm <: ShortestPathAlgorithm
    all_paths::Bool
    track_vertices::Bool

    DijkstraShortestPathAlgorithm() = new(false, false)
end

struct BellmanFordShortestPathAlgorithm <: ShortestPathAlgorithm end


shortest_paths(g::AbstractGraph, ss, distmx=weights(g), alg::DijkstraShortestPathAlgorithm=DijkstraShortestPathAlgorithm()) =
    DijkstraShortestPathResults(dijkstra_shortest_paths(g, ss, distmx, allpaths=alg.all_paths, trackvertices=alg.track_vertices))
    
shortest_paths(g::AbstractGraph, ss, distmx, alg::BellmanFordShortestPathAlgorithm) =
    BellmanFordShortestPathResults(bellman_ford_shortest_paths(g, ss, distmx))

shortest_paths(g::AbstractGraph, ss, alg::BellmanFordShortestPathAlgorithm) =
    BellmanFordShortestPathResults(bellman_ford_shortest_paths(g, ss, weights(g)))
# function shortest_paths(g::AbstractGraph, s::sources=[], t::targets=[], alg::SPAlgorithm, options::LGOpts) :: SPResults


