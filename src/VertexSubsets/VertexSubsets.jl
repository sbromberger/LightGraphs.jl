module VertexSubsets
using LightGraphs
using LightGraphs: shuffle!
using DataStructures: PriorityQueue, dequeue!, peek
using Random: AbstractRNG, GLOBAL_RNG, shuffle, randperm

"""
    abstract type VertexSubset

An abstract type used to denote a subset of vertices computed from various algorithms.
"""
abstract type VertexSubset end

"""
    struct DegreeSubset <: VertexSubset

A struct representing a degree-based greedy algorithm to calculate the vertex subset.
"""
struct DegreeSubset <: VertexSubset end

"""
    struct RandomSubset <: VertexSubset

A struct representing an algorithm to calculate the minimum [dominating set](https://en.wikipedia.org/wiki/Dominating_set)
of a graph.

### Optional Arguments
- `rng<:AbstractRNG`: override default random number generator (`GLOBAL_RNG`).
"""
struct RandomSubset{R<:AbstractRNG} <: VertexSubset
    rng::R
end
RandomSubset(;rng=GLOBAL_RNG) = RandomSubset(rng)

"""
    struct MinimalSubset <: VertexSubset

An alias for [`RandomSubset`](@ref).
"""
const MinimalSubset = RandomSubset

"""
    struct MaximalSubset <: VertexSubset

An alias for [`RandomSubset`](@ref).
"""
const MaximalSubset = RandomSubset

"""
    vertex_cover(g, alg::VertexSubset)

Return the vertex cover of graph `g` using [`VertexCover`](@ref) algorithm `alg` as a vector
of vertices in the cover.

An vertex is said to be covered if it has at least one adjacent edge end-point in the vertex cover.
"""
function vertex_cover end

"""
    dominating_set(g, alg::VertexSubset)

Using a [`VertexSubset`](@ref) algorithm, find a set of vertices that consitute a dominating set (all vertices
in `g` are either adjacent to a vertex in the set or is a vertex in the set) and it is not possible to delete a
vertex from the set without sacrificing the dominating property.
#
### Implementation Notes
A vertex is said to be dominated if it is in the dominating set or adjacent to a vertex
in the dominating set.
"""
function dominating_set end

"""
    independent_set(g, alg::VertexSubset)

Obtain an [independent set](https://en.wikipedia.org/wiki/Independent_set_(graph_theory)) of
`g` using the specifed [`VertexSubset`](@ref) algorithm.

### Implementation Notes
A vertex is said to be valid if it is not in the independent set or adjacent to any vertex
in the independent set.
"""
function indepndent_set end

include("degree_vertex_cover.jl")
include("random_vertex_cover.jl")
include("degree_dom_set.jl")
include("minimal_dom_set.jl")
include("degree_ind_set.jl")
include("maximal_ind_set.jl")

end # module
