module Coloring

using Base.Threads
using SimpleTraits
using Distributed
using Random: AbstractRNG, GLOBAL_RNG, shuffle, shuffle!
using DataStructures: Queue, enqueue!, dequeue!
using LightGraphs
using LightGraphs.Connectivity: connected_components, UnionMerge, DFSQ

"""
    struct GraphColoring{T}

Store the number of colors used and mapping from vertex to color
"""
struct GraphColoring{T <: Integer}
    num_colors::T
    colors::Vector{T}
end

best_color(c1::GraphColoring, c2::GraphColoring) = c1.num_colors < c2.num_colors ? c1 : c2

"""
    abstract type ColoringAlgorithm

An abstract type representing an algorithm to be used for [`color`](@ref).
"""
abstract type ColoringAlgorithm end

abstract type ParallelColoringAlgorithm <: ColoringAlgorithm end

abstract type ThreadedColoringAlgorithm <: ParallelColoringAlgorithm end

abstract type DistributedColoringAlgorithm <: ParallelColoringAlgorithm end

"""
	color(g, alg::ColoringAlgorithm)

Color graph using a [`ColoringAlgorithm`](@ref) and return [`GraphColoring`](@ref).
"""
function color end

include("bipartition.jl")
include("fixed_color.jl")
include("random_color.jl")
include("distributed-random_color.jl")

end # module
