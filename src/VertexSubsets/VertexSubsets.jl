module VertexSubsets
using LightGraphs
using LightGraphs: shuffle!
using DataStructures: PriorityQueue, dequeue!, peek
using Random: AbstractRNG, GLOBAL_RNG, shuffle, randperm
using Base.Threads: @threads, nthreads

"""
    abstract type VertexSubset

An abstract type used to denote a subset of vertices computed from various algorithms.
"""
abstract type VertexSubset end

"""
    vertex_cover(g, alg::VertexSubset)

Return the vertex cover of graph `g` using [`VertexCover`](@ref) algorithm `alg` as a vector
of vertices in the cover.
"""
function vertex_cover end

"""
    dominating_set(g, alg::VertexSubset)

Using a [`VertexSubset`](@ref) algorithm, find a set of vertices that consitute a dominating set (all vertices
in `g` are either adjacent to a vertex in the set or is a vertex in the set) and it is not possible to delete a
vertex from the set without sacrificing the dominating property.

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
A vertex is said to be independent if it is not in the independent set or adjacent to any vertex
in the independent set.
"""
function indepndent_set end

"""
    struct DegreeSubset <: VertexSubset

A struct representing a degree-based greedy algorithm to calculate the
approximate vertex cover, minimal dominating set or maximal independent set.
"""
struct DegreeSubset <: VertexSubset end

"""
    struct RandomSubset <: VertexSubset

A struct representing an algorithm to calculate the approximate vertex cover,
minimal dominating set or maximal independent set.

### Optional Arguments
- `rng<:AbstractRNG`: override default random number generator (`GLOBAL_RNG`).
"""
struct RandomSubset{R<:AbstractRNG} <: VertexSubset
    rng::R
end
RandomSubset(;rng=GLOBAL_RNG) = RandomSubset(rng)

"""
    struct DistributedRandomSubset <: VertexSubset

A struct representing an algorithm to calculate the approximate vertex cover,
minimal dominating set or maximal independent set of a graph performing `reps` times
in parallel, returning the minimum (in case of vertex cover and dominating set)
or maximum (in case of independent set) result.

### Required Fields
`reps::Integer`: the number of times to perform the calculation.

### Optional Arguments
- `rng<:AbstractRNG`: override default random number generator (`GLOBAL_RNG`).
"""
struct DistributedRandomSubset{R<:AbstractRNG} <: VertexSubset
    reps::Int
    rng::R
end
DistributedRandomSubset(reps::Int; rng=GLOBAL_RNG) = DistributedRandomSubset(reps, rng)

"""
    struct ThreadedRandomSubset <: VertexSubset

A struct representing an algorithm to calculate the approximate vertex cover,
minimal dominating set or maximal independent set of a graph performing `reps` times
in parallel using threads, returning the minimum (in case of vertex cover and dominating set)
or maximum (in case of independent set) result.

### Required Fields
`reps::Integer`: the number of times to perform the calculation.

### Optional Arguments
- `rng<:AbstractRNG`: override default random number generator (`GLOBAL_RNG`).
"""
struct ThreadedRandomSubset{R<:AbstractRNG} <: VertexSubset
    reps::Int
    rng::R
end
ThreadedRandomSubset(reps::Int; rng=GLOBAL_RNG) = ThreadedRandomSubset(reps, rng)

include("degree_vertex_cover.jl")
include("random_vertex_cover.jl")
include("threaded-random_vertex_cover.jl")
include("distributed-random_vertex_cover.jl")

include("degree_dom_set.jl")
include("random_dom_set.jl")
include("threaded-random_dom_set.jl")
include("distributed-random_dom_set.jl")

include("degree_ind_set.jl")
include("random_ind_set.jl")
include("threaded-random_ind_set.jl")
include("distributed-random_ind_set.jl")
include("luby_maximal_ind_set.jl")

end # module
