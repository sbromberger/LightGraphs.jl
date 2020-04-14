module Measurements

using Base.Threads
using LightGraphs
using LightGraphs.ShortestPaths:SSSPAlgorithm, Dijkstra, BFS, shortest_paths, distances, AbstractGraphAlgorithm

"""
    abstract type GraphMeasurement

A structure representing a common measurement of a graph.
"""
abstract type GraphMeasurement end


include("eccentricity.jl")

end # module
