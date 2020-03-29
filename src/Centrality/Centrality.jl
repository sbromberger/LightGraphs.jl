module Centrality

# using LightGraphs
using LightGraphs
using LightGraphs.ShortestPaths
using ArnoldiMethod: LM
using LightGraphs.LinAlg: eigs
using LinearAlgebra: I, norm
using SparseArrays: sparse
using Distributed: @distributed
using Base.Threads: @threads, nthreads

import Base: show

abstract type CentralityMeasure end

struct ConvergenceError <: Exception
    m::String
end
Base.show(io::IO, e::ConvergenceError) = println(io, "ConvergenceError: $m")

"""
    centrality(g[, distmx], alg)

Calculate the [centrality](https://en.wikipedia.org/wiki/Centrality) of the graph `g`
using algorithm `alg`, optionally with distances between vertices specified in `distmx`.
Return a vector representing the appropriate centrality values mapped to the vertices
of the graph (or the selected subset, if the algorithm supports it.)
"""
centrality(g::AbstractGraph, alg::CentralityMeasure) = centrality(g, weights(g), alg)

include("betweenness.jl")
include("threaded-betweenness.jl")
include("distributed-betweenness.jl")
include("closeness.jl")
include("threaded-closeness.jl")
include("distributed-closeness.jl")
include("degree.jl")
include("eigenvector.jl")
include("katz.jl")
include("pagerank.jl")
include("threaded-pagerank.jl")
include("radiality.jl")
include("threaded-radiality.jl")
include("distributed-radiality.jl")
include("stress.jl")

export centrality
export Betweenness, Closeness, Degree, Eigenvector, Katz, PageRank, Radiality, Stress

end #module
