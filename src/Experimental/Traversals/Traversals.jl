module Traversals

# This module does not export much. The primary reasons are that exporting would increase the
# likelihood of name conflicts, and because the functions here should be used only by developers
# to create new graph algorithms that rely on breadth-first or depth-first search traversals.

using LightGraphs
using SimpleTraits
"""
    abstract type TraversalAlgorithm

`TraversalAlgorithm` is the abstract type used to specify breadth-first traversal (`BFS`) or
depth-first traversal (`DFS`) for the various traversal functions.
"""
abstract type TraversalAlgorithm end

"""
    abstract type AbstractTraversalState

`AbstractTraversalState` is the abstract type used to hold mutable states
for various traversal algorithms (see `traverse_graph`](@ref)).

When creating concrete types, you should override the following functions where relevant. These functions
are listed in order of occurrence in the traversal:
- `neighborfn(<:AbstractTraversalState)`: use `outneighbors` (default) or `inneighbors`.
- `initfn!(<:AbstractTraversalState, u::Integer)`: runs prior to traversal, used to set initial state.
- `previsitfn!(<:AbstractTraversalState, u::Integer)`: runs prior to neighborhood discovery for vertex `u`.
- `visitfn!(<:AbstractTraversalState, u::Integer, v::Integer)`: runs for each neighbor `v` (newly-discovered or not) of vertex `u`.
- `newvisitfn!(<:AbstractTraversalState, u::Integer, v::Integer)`: runs when a new neighbor `v` of vertex `u` is discovered.
- `postvisitfn!(<:AbstractTraversalState, u::Integer)`: runs after neighborhood discovery for vertex `u`.
- `postlevelfn!(<:AbstractTraversalState)`: runs after each traversal level.

Each of these functions should return a boolean. If the return value of the function is `false`, the traversal will return the state
immediately. Otherwise, the traversal will continue.

For better performance, use the `@inline` directive and make your functions branch-free.
"""
abstract type AbstractTraversalState end

@inline initfn!(::AbstractTraversalState, u) = true
@inline previsitfn!(::AbstractTraversalState, u) = true
@inline newvisitfn!(::AbstractTraversalState, u, v) = true
@inline visitfn!(::AbstractTraversalState, u, v) = true
@inline postvisitfn!(::AbstractTraversalState, u) = true
@inline postlevelfn!(::AbstractTraversalState) = true
@inline neighborfn(::AbstractTraversalState) = outneighbors

##############
# functions common to both BFS and DFS
##############
traverse_graph!(g::AbstractGraph, s::Integer, alg, state, neighborfn) = traverse_graph!(g, [s], alg, state, neighborfn)
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

"""
    parents(g, s, alg, dir=:out)

Return a vector of parent vertices indexed by vertex using [`TraversalAlgorithm`](@ref) `alg` starting with
vertex `s`. If `dir` is specified, use the corresponding edge direction (`:in` and `:out` are acceptable
values).

### Performance
This implementation is designed to perform well on large graphs. There are
implementations which are marginally faster in practice for smaller graphs,
but the performance improvements using this implementation on large graphs
can be significant.
"""
parents(g::AbstractGraph, s::Integer, alg::TraversalAlgorithm, dir = :out) =
    (dir == :out) ? parents(g, s, alg, outneighbors) : parents(g, s, alg, inneighbors)

mutable struct ParentState{T<:Integer} <: AbstractTraversalState
    parents::Vector{T}
end

@inline function newvisitfn!(s::ParentState, u, v) 
    s.parents[v] = u
    return true
end

function parents(g::AbstractGraph{T}, s::Integer, alg::TraversalAlgorithm, neighborfn::Function) where T
    parents = zeros(T, nv(g))
    state = ParentState(parents)

    traverse_graph!(g, s, alg, state, neighborfn)
    return state.parents
end

include("bfs.jl")
include("dfs.jl")

export visited_vertices, parents, distances, topological_sort

end  # module
