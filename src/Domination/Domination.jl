module Domination

using LightGraphs
using Random: AbstractRNG, GLOBAL_RNG, randperm
using DataStructures: PriorityQueue, dequeue!, peek

"""
    abstract type DominatingSet

An abstract type used for [dominating set](https://en.wikipedia.org/wiki/Dominating_set) algorithms.
"""
abstract type DominatingSet end

"""
    dominating_set(g, alg)

Using a [`DominatingSet`](@ref) algorithm, find a set of vertices that consitute a dominating set (all vertices
in `g` are either adjacent to a vertex in the set or is a vertex in the set) and it is not possible to delete a
vertex from the set without sacrificing the dominating property.
"""
function dominating_set end

include("degree_dom_set.jl")
include("minimal_dom_set.jl")

end #module
