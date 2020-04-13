module Measurements

using LightGraphs
using LightGraphs.ShortestPaths:ShortestPathAlgorithm, Dijkstra, BFS, shortest_paths, distances

"""
    abstract type GraphMeasurement

A structure representing a common measurement of a graph.
"""
abstract type GraphMeasurement end

include("center.jl")
include("defaultdistance.jl")
include("diameter.jl")
include("eccentricity.jl")
include("periphery.jl")
include("radius.jl")

"""
    metric(g::AbstractGraph[, vs[, distmx]], measurement::GraphMeasurement)

Return the result of the [graph measurement](@ref GraphMeasurement) specified
by `measurement` on the graph `g`. If `vs` or `distmx` is specified, the eccentricity
calculation will be performed explicitly; if both are omitted, the eccentricies
are assumed to be contained within `measurement`.
"""
function metric end

function _associated_extreme end

function _metric(g::AbstractGraph, vs, distmx::AbstractMatrix, gm::GraphMeasurement, use_eccs::Bool, use_dists::Bool)
    eccs = 
        if use_eccs
            gm.eccentricities
        elseif use_dists
            eccentricities(g, vs, distmx)
        elseif vs == 0
            eccentricity(g)
        else
            eccentricity(g, vs)
        end
    return _associated_extreme(gm)(eccs)
end

metric(g::AbstractGraph, vs, distmx::AbstractMatrix, gm::GraphMeasurement) =
    _metric(g, vs, distmx, gm, false, true)

metric(g::AbstractGraph, vs, gm::GraphMeasurement) = _metric(g, vs, zeros(0,0), gm, false, false)
metric(g::AbstractGraph, gm::GraphMeasurement) = _metric(g, 0, zeros(0,0), gm, !isnothing(gm.eccentricities), false)

"""
    abstract type VertexSubset

A type representing a subset of vertices induced by a graph measurement.
"""
abstract type VertexSubset end

"""
    vertex_subset(g::AbstractGraph[, vs][, distmx], vsubset::VertexSubset)

Return the result of the [vertex subset](@ref VertexSubset) specified
by `vsubset` on the graph `g` with optional distances specified by `distmx`.
If `vs` is specified, the eccentricity calculation will be performed
explicitly; if `vs` is omitted, the eccentricies are assumed to be contained
within `vsubset`.
"""
function vertex_subset end
function _associated_metric end

function _vertex_subset(g::AbstractGraph, vs, distmx::AbstractMatrix, vsubset::VertexSubset, use_eccs::Bool, use_dists::Bool)
    eccs = 
        if use_eccs
            vsubset.eccentricities
        elseif use_dists
            eccentricity(g, vs, distmx)
        else
            eccentricity(g, vs)
        end
    m = metric(g, eccs, _associated_metric(vsubset)())
    return findall(x==m, eccs)
end

vertex_subset(g::AbstractGraph, vs, distmx::AbstractMatrix, vsubset::VertexSubset) = 
    _vertex_subset(g, vs, distmx, vsubset, false, true)

vertex_subset(g::AbstractGraph, vs, vsubset::VertexSubset) =
    _vertex_subset(g, vs, zeros(0,0), vsubset, false, false)

vertex_subset(g::AbstractGraph, vsubset::VertexSubset) =
   _vertex_subset(g, 0, zeros(0,0), vsubset, true, false)


end # module
