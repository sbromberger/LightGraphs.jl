module SimpleGraphs

using LightGraphs
using LightGraphs: insorted
using LightGraphs.SimpleGraphsCore
using LightGraphs.SimpleGraphsCore: deepcopy_adjlist

import LightGraphs.SimpleGraphsCore: AbstractSimpleGraph, SimpleGraph, SimpleDiGraph, AbstractSimpleEdge, SimpleGraphEdge, SimpleDiGraphEdge, SimpleEdge, SimpleGraphFromIterator, SimpleDiGraphFromIterator, fadj, badj, adj, add_vertex!, add_edge!, add_vertices!, rem_vertex!, rem_edge!, rem_vertices!, merge_vertices, merge_vertices!, _SimpleGraphFromIterator, _SimpleDiGraphFromIterator, squash
using SparseArrays
using LinearAlgebra
using SimpleTraits

import Base:
    eltype, show, ==, Pair, Tuple, copy, length, issubset, zero, in, iterate, reverse!

import LightGraphs: reverse, symmetric_difference
import LightGraphs.ShortestPaths: has_negative_weight_cycle

export AbstractSimpleGraph, SimpleGraph, SimpleDiGraph, AbstractSimpleEdge, SimpleEdge, SimpleGraphFromIterator, SimpleDiGraphFromIterator, reverse!
using Random: GLOBAL_RNG, AbstractRNG

"""
    module SimpleGraphs

This module is the user-facing SimpleGraphs module.
"""
SimpleGraphs

include("overrides/operators.jl")
include("overrides/shortestpaths.jl")
include("Generators/Generators.jl")
end # module
