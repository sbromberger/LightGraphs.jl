module Traversals

using LightGraphs
using LightGraphs.Traversals
using Base.Threads
using Distributed
import LightGraphs.Traversals: parents, TraversalState, TraversalAlgorithm, distances, traverse_graph!, preinitfn!, initfn!, previsitfn!, visitfn!, postvisitfn!, postlevelfn!

import Base: push!, popfirst!, isempty, getindex

abstract type ParallelTraversalAlgorithm <: TraversalAlgorithm end
abstract type ThreadedTraversalAlgorithm <: ParallelTraversalAlgorithm end
abstract type DistributedTraversalAlgorithm <: ParallelTraversalAlgorithm end

@inline previsitfn!(s, v, t) = true
@inline visitfn!(s, u, v, t) = true
@inline newvisitfn!(s, u, v, t) = true
@inline postvisitfn!(s, u, t) = true
@inline postlevelfn!(s, t) = true

include("breadthfirst.jl")
include("gdistances.jl")
include("greedy_color.jl")

export ParallelTraversalAlgorithm, ThreadedTraversalAlgorithm, DistributedTraversalAlgorithm
export ThreadedBreadthFirst

end
