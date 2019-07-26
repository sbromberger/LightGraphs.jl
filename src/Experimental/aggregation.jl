using LightGraphs:DijkstraState
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
function getproperty(dspr::DijkstraShortestPathResults, sym::Symbol)
           if sym === :paths
               return enumerate_paths(DijkstraState(dspr))
           else # fallback to getfield
               return getfield(dspr, sym)
           end
       end

convert(::Type{<:DijkstraShortestPathResults}, ds::DijkstraState) =
    DijkstraShortestPathResults(ds.parents, ds.dists, ds.predecessors, ds.pathcounts, ds.closest_vertices)

convert(::Type{<:DijkstraState}, dspr::DijkstraShortestPathResults) =
    DijkstraState(dspr.parents, dspr.dists, dspr.predecessors, dspr.pathcounts, dspr.closest_vertices)

DijkstraShortestPathResults(ds::DijkstraState) = convert(DijkstraShortestPathResults, ds)
DijkstraState(dspr::DijkstraShortestPathResults) = convert(DijkstraState, dspr)

abstract type AbstractGraphAlgorithm end
abstract type ShortestPathAlgorithm <: AbstractGraphAlgorithm end
struct DijkstraShortestPathAlgorithm <: ShortestPathAlgorithm
    all_paths::Bool
    track_vertices::Bool

    DijkstraShortestPathAlgorithm() = new(false, false)
end


shortest_paths(g::AbstractGraph, ss, distmx=weights(g), alg::DijkstraShortestPathAlgorithm=DijkstraShortestPathAlgorithm()) =
    DijkstraShortestPathResults(dijkstra_shortest_paths(g, ss, distmx, allpaths=alg.all_paths, trackvertices=alg.track_vertices))
    

# function shortest_paths(g::AbstractGraph, s::sources=[], t::targets=[], alg::SPAlgorithm, options::LGOpts) :: SPResults


