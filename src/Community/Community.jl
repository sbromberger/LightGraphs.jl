module Community

using LightGraphs
using LightGraphs.Connectivity
using SimpleTraits
using LightGraphs: getRNG, range_shuffle!

"""
    abstract type ClusteringScope

A type representing either a [local](@ref Local) or [global](@ref Global) scope.
"""
abstract type ClusteringScope end

"""
    abstract type CommunityDetectionAlgorithm

A type representing a community detection algorithm.
"""
abstract type CommunityDetectionAlgorithm end

"""
    abstract type CorePeripheryAlgorithm

A type representing a core-periphery algorithm.
"""
abstract type CorePeripheryAlgorithm end

"""
    core_periphery(g, alg=Degree())

Compute the core-periphery for graph `g` using [`CorePeripheryAlgorithm`](@ref) `alg`.
Return the vertex assignments (`1` for core and `2` for periphery) for each node in `g`.

"""
function core_periphery end
core_periphery(g::AbstractGraph) = core_periphery(g, Degree())

"""
    communities(g, alg::CommunityDetectionAlgorithm)

Community detection using the specified [`CommunityDetectionAlgorithm`](@ref).
Communities are potentionally overlapping.

The output varies depending on algorithm used.
For [`CliquePercolation`](@ref), return a vector of vectors `c` such that `c[i]` is the set of vertices in community `i`.

For [`LabelPropagation](@ref), return two vectors: the first is the label number assigned to each node, and
the second is the convergence history for each node.
"""
function communities end

include("clique_percolation.jl")
include("cliques.jl")
include("clustering.jl")
include("core-periphery.jl")
include("label_propagation.jl")
include("modularity.jl")

end #module
