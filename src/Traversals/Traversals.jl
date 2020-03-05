module Traversals

using LightGraphs
using LightGraphs: getRNG
using SimpleTraits
using DataStructures: PriorityQueue, enqueue!, dequeue!
using Random: shuffle, shuffle!, randsubseq!

"""
    abstract type TraversalAlgorithm

`TraversalAlgorithm` is the abstract type used to specify breadth-first traversal (`BreadthFirst`) or
depth-first traversal (`DepthFirst`) for the various traversal functions.
"""
abstract type TraversalAlgorithm end

"""
    abstract type AbstractTraversalState

`AbstractTraversalState` is the abstract type used to hold mutable states
for various traversal algorithms (see [`traverse_graph!`](@ref)).

When creating concrete types, you should override the following functions where relevant. These functions
are listed in order of occurrence in the traversal:
- [`preinitfn!(<:AbstractTraversalState, visited::BitVector)`](@ref): runs after visited initialization, used to modify initial visited state.
- [`initfn!(<:AbstractTraversalState, u::Integer)`](@ref): runs prior to traversal, used to set initial state.
- [`previsitfn!(<:AbstractTraversalState, u::Integer)`](@ref): runs prior to neighborhood discovery for vertex `u`.
- [`visitfn!(<:AbstractTraversalState, u::Integer, v::Integer)`](@ref): runs for each neighbor `v` (newly-discovered or not) of vertex `u`.
- [`newvisitfn!(<:AbstractTraversalState, u::Integer, v::Integer)`](@ref): runs when a new neighbor `v` of vertex `u` is discovered.
- [`postvisitfn!(<:AbstractTraversalState, u::Integer)`](@ref): runs after neighborhood discovery for vertex `u`.
- [`postlevelfn!(<:AbstractTraversalState)`](@ref): runs after each traversal level.

Each of these functions should return a boolean. If the return value of the function is `false`, the traversal will return the state
immediately. Otherwise, the traversal will continue.

For better performance, use the `@inline` directive and make your functions branch-free.
"""
abstract type AbstractTraversalState end

"""
    preinitfn!(state, visited)

Modify [`AbstractTraversalState`](@ref) `state` after intiialization of the visited
bitvector; and return `true` if successful; `false` otherwise. `preinitfn!` will
be called once. It is typically used to modify the `visited` bitvector before
traversals begin.
"""
@inline preinitfn!(::AbstractTraversalState, visited) = true
"""
    initfn!(state, u)

Modify [`AbstractTraversalState`](@ref) `state` on initialization of traversal
with source vertices, and return `true` if successful; `false` otherwise.
`initfn!` will be called once for each vertex passed to [`traverse_graph!`](@ref).
"""
@inline initfn!(::AbstractTraversalState, u) = true

"""
    previsitfn!(state, u)

Modify [`AbstractTraversalState`](@ref) `state` before examining neighbors of vertex `u`,
and return `true` if successful; `false` otherwise.
"""
@inline previsitfn!(::AbstractTraversalState, u) = true

"""
    newvisitfn!(state, u, v)

Modify [`AbstractTraversalState`](@ref) `state` when the first edge between `u` and `v` is encountered,
and return `true` if successful; `false` otherwise.
"""
@inline newvisitfn!(::AbstractTraversalState, u, v) = true

"""
    visitfn!(state, u, v)

Modify [`AbstractTraversalState`](@ref) `state` when the edge between `u` and `v` is encountered,
and return `true` if successful; `false` otherwise. Note: `visitfn!` may be called multiple times
per edge, depending on the traversal algorithm, for a function that operates on the first occurrence
only, use [`newvisitfn!`](@ref).
"""
@inline visitfn!(::AbstractTraversalState, u, v) = true

"""
    postvisitfn!(state, u)

Modify [`AbstractTraversalState`](@ref) `state` after having examined all neighbors of vertex `u`,
and return `true` if successful; `false` otherwise.
"""
@inline postvisitfn!(::AbstractTraversalState, u) = true
"""
    postlevelfn!(state)

Modify [`AbstractTraversalState`](@ref) `state` before moving to the next vertex in the traversal algorithm,
and return `true` if successful; `false` otherwise.
"""
@inline postlevelfn!(::AbstractTraversalState) = true

##############
# functions common to both BreadthFirst and DepthFirst
##############
"""
    traverse_graph!(g, s, alg, state)
    traverse_graph!(g, ss, alg, state)

Traverse a graph `g` from source vertex `s` / vertices `ss` keeping track of `state`. Return `true` if
traversal finished normally; `false` if one of the visit functions returned `false` (see )
"""
traverse_graph!(g::AbstractGraph, s::Integer, alg, state) = traverse_graph!(g, [s], alg, state)

struct VisitState{T<:Integer} <: AbstractTraversalState
    visited::Vector{T}
end

@inline function initfn!(s::VisitState, u)
    push!(s.visited, u)
    return true
end
@inline function newvisitfn!(s::VisitState, u, v)
    push!(s.visited, v)
    return true
end

"""
    visited_vertices(g, s, alg)
    visited_vertices(g, ss, alg)

Return a vector representing the vertices of `g` visited in order by [`TraversalAlgorithm`](@ref) `alg`
starting at vertex `s` (vertices `ss`).
"""
function visited_vertices(
    g::AbstractGraph{U},
    ss::AbstractVector,
    alg::TraversalAlgorithm
    ) where U<:Integer

    v = Vector{U}()
    sizehint!(v, nv(g))  # actually just the largest connected component, but we'll use this.
    state = VisitState(v)
    traverse_graph!(g, ss, alg, state)

    return state.visited
end

visited_vertices(g::AbstractGraph, s::Integer, alg::TraversalAlgorithm) = visited_vertices(g, [s], alg)


mutable struct ParentState{T<:Integer} <: AbstractTraversalState
    parents::Vector{T}
end

@inline function newvisitfn!(s::ParentState, u, v) 
    s.parents[v] = u
    return true
end

"""
    parents(g, s, alg)

Return a vector of parent vertices indexed by vertex using [`TraversalAlgorithm`](@ref) `alg` starting with
vertex `s`. 

### Performance
This implementation is designed to perform well on large graphs. There are
implementations which are marginally faster in practice for smaller graphs,
but the performance improvements using this implementation on large graphs
can be significant.
"""
function parents(g::AbstractGraph{T}, s::Integer, alg::TraversalAlgorithm) where T
    parents = zeros(T, nv(g))
    state = ParentState(parents)

    traverse_graph!(g, s, alg, state)
    return state.parents
end

"""
    tree(p)

Return a directed acyclic graph based on a [`parents`](@ref) vector `p`.
"""
function tree(p::AbstractVector{T}) where T <: Integer
    n = T(length(p))
    t = DiGraph{T}(n)
    for (v, u) in enumerate(p)
        if u > zero(T) && u != v
            add_edge!(t, u, v)
        end
    end
    return t
end


"""
    tree(g, s, alg)

Return a directed acyclic graph based on traversal of the graph `g` starting with source vertex `s`
using algorithm `alg`.
"""
function tree(g::AbstractGraph, s::Integer, alg::TraversalAlgorithm)
    p = parents(g, s, alg)
    return tree(p)
end

include("bfs.jl")
include("bipartition.jl")
include("dfs.jl")
include("diffusion.jl")
include("greedy_color.jl")
include("maxadjvisit.jl")
include("randomwalks.jl")

export tree, parents, visited_vertices
export BreadthFirst, distances, has_path
export is_bipartite, bipartite_map
export DepthFirst, is_cyclic, topological_sort, CycleError 
export randomwalk, self_avoiding_walk, non_backtracking_randomwalk
export diffusion, diffusion_rate
export greedy_color
export mincut, maximum_adjacency_visit
end #module
