module VertexCover
using LightGraphs
using LightGraphs: shuffle!
using DataStructures: PriorityQueue, dequeue!, peek
using Random: AbstractRNG, GLOBAL_RNG, shuffle

"""
    abstract type VertexCovering

An abstract type used in [`vertex_cover`](@ref).
"""
abstract type VertexCovering end

"""
    vertex_cover(g, alg::VertexCovering)

Return the vertex cover of graph `g` using [`VertexCover`](@ref) algorithm `alg` as a vector
of vertices in the cover.

An vertex is said to be covered if it has at least one adjacent edge end-point in the vertex cover.
"""
function vertex_cover end

include("degree_vertex_cover.jl")
include("random_vertex_cover.jl")

end # module
