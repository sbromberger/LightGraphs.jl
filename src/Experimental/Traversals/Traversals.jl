module Traversals

# This module does not export much. The primary reasons are that exporting would increase the
# likelihood of name conflicts, and because the functions here should be used only by developers
# to create new graph algorithms that rely on breadth-first or depth-first search traversals.

using LightGraphs

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

When creating concrete types, you should override the following functions where relevant:
- `initfn!(<:AbstractTraversalState, u::Integer)`: runs prior to traversal, used to set initial state.
- `previsitfn!(<:AbstractTraversalState, u::Integer)`: runs prior to neighborhood discovery for vertex `u`.
- `newvisitfn!(<:AbstractTraversalState, u::Integer, v::Integer)`: runs when a new neighbor `v` of vertex `u` is discovered.
- `visitfn!(<:AbstractTraversalState, u::Integer, v::Integer)`: runs for each neighbor `v` (newly-discovered or not) of vertex `u`.
- `postvisitfn!(<:AbstractTraversalState, u::Integer)`: runs after neighborhood discovery for vertex `u`.
- `postlevelfn!(<:AbstractTraversalState)`: runs after each traversal level.
- `neighborfn`: use `outneighbors` (default) or `inneighbors`.
For better performance, use the `@inline` directive and make your functions branch-free.
"""
abstract type AbstractTraversalState end

@inline initfn!(::AbstractTraversalState, u) = nothing
@inline previsitfn!(::AbstractTraversalState, u) = nothing
@inline newvisitfn!(::AbstractTraversalState, u, v) = nothing
@inline visitfn!(::AbstractTraversalState, u, v) = nothing
@inline postvisitfn!(::AbstractTraversalState, u) = nothing
@inline postlevelfn!(::AbstractTraversalState) = nothing
@inline neighborfn(::AbstractTraversalState) = outneighbors

include("bfs.jl")

export visited_vertices, parents, distances

end  # module
