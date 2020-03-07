module Traversals

using Base.Threads
using Distributed
using LightGraphs
using LightGraphs: getRNG # TODO 2.0.0: remove this
using SimpleTraits
using DataStructures: PriorityQueue, enqueue!, dequeue!
using Random: shuffle, shuffle!, randsubseq!, AbstractRNG, GLOBAL_RNG
import Base:show

"""
    TraversalError <: Exception

An exception thrown by a traversal function indicating that a visitor function called by
[`traverse_graph!`](@ref) returned false. For some functions (notably [`has_path`](@ref)),
a return value of `false` does not indicate an error and therefore no exception is thrown.
"""
struct TraversalError <: Exception end
show(io::IO, ::TraversalError) = println(io, "An error was encountered while traversing the graph.")

"""
    abstract type TraversalAlgorithm

`TraversalAlgorithm` is the abstract type used to specify breadth-first traversal (`BreadthFirst`) or
depth-first traversal (`DepthFirst`) for the various traversal functions.
"""
abstract type TraversalAlgorithm end

"""
    abstract type ParallelTraversalAlgorithm <: TraversalAlgorithm

`ParallelTraversalAlgorithm` is the abstract type used to specify a threaded or distributed traversal
for the various traversal functions.
"""
abstract type ParallelTraversalAlgorithm <: TraversalAlgorithm end

"""
    abstract type ThreadedTraversalAlgorithm <: ParallelTraversalAlgorithm

`ThreadedTraversalAlgorithm` is the abstract type used to specify a threaded traversal
for the various traversal functions.
"""
abstract type ThreadedTraversalAlgorithm <: ParallelTraversalAlgorithm end

"""
    abstract type DistributedTraversalAlgorithm <: ParallelTraversalAlgorithm

`DistributedTraversalAlgorithm` is the abstract type used to specify a distributed (multi-node)
traversal for the various traversal functions.
"""
abstract type DistributedTraversalAlgorithm <: ParallelTraversalAlgorithm end

"""
    abstract type TraversalState

`TraversalState` is the abstract type used to hold mutable states
for various traversal algorithms (see [`traverse_graph!`](@ref)).

When creating concrete types, you should override the following functions where relevant. These functions
are listed in order of occurrence in the traversal:
- [`preinitfn!(<:TraversalState, visited::BitVector)`](@ref): runs after visited initialization, used to modify initial visited state.
- [`initfn!(<:TraversalState, u::Integer)`](@ref): runs prior to traversal, used to set initial state.
- [`previsitfn!(<:TraversalState, u::Integer)`](@ref): runs prior to neighborhood discovery for vertex `u`.
- [`visitfn!(<:TraversalState, u::Integer, v::Integer)`](@ref): runs for each neighbor `v` (newly-discovered or not) of vertex `u`.
- [`newvisitfn!(<:TraversalState, u::Integer, v::Integer)`](@ref): runs when a new neighbor `v` of vertex `u` is discovered.
- [`postvisitfn!(<:TraversalState, u::Integer)`](@ref): runs after neighborhood discovery for vertex `u`.
- [`postlevelfn!(<:TraversalState)`](@ref): runs after each traversal level.

Each of these functions should return a boolean. If the return value of the function is `false`, the traversal will return the state
immediately. Otherwise, the traversal will continue.

For [`ParallelTraversalState`], each `visit` function may receive an additional `t::Integer` argument that specifies either the
thread ID (for [`ThreadedTraversalState`](@ref)) or the cpu ID (for [`DistributedTraversalState`](@ref)).

For better performance, use the `@inline` directive and make your functions branch-free.
"""
abstract type TraversalState end

"""
    preinitfn!(state, visited)

Modify [`TraversalState`](@ref) `state` after intiialization of the visited
bitvector; and return `true` if successful; `false` otherwise. `preinitfn!` will
be called once. It is typically used to modify the `visited` bitvector before
traversals begin.
"""
@inline preinitfn!(::TraversalState, visited) = true
"""
    initfn!(state, u)

Modify [`TraversalState`](@ref) `state` on initialization of traversal
with source vertices, and return `true` if successful; `false` otherwise.
`initfn!` will be called once for each vertex passed to [`traverse_graph!`](@ref).
"""
@inline initfn!(::TraversalState, u) = true

"""
    previsitfn!(state, u)
    previsitfn!(state, u, t)

Modify [`TraversalState`](@ref) `state` before examining neighbors of vertex `u`,
and return `true` if successful; `false` otherwise. For parallel algorithms, the thread ID
or the CPU ID will be passed in `t`.
"""
@inline previsitfn!(::TraversalState, u) = true
@inline previsitfn!(s::TraversalState, u, ::Integer) = previsitfn!(s, u)

"""
    newvisitfn!(state, u, v)
    newvisitfn!(state, u, v, t)

Modify [`TraversalState`](@ref) `state` when the first edge between `u` and `v` is encountered,
and return `true` if successful; `false` otherwise. For parallel algorithms, the thread ID
or the CPU ID will be passed in `t`.

"""
@inline newvisitfn!(::TraversalState, u, v) = true
@inline newvisitfn!(s::TraversalState, u, v, t::Integer) = newvisitfn!(s, u, v)

"""
    visitfn!(state, u, v)
    visitfn!(state, u, v, t)

Modify [`TraversalState`](@ref) `state` when the edge between `u` and `v` is encountered,
and return `true` if successful; `false` otherwise. Note: `visitfn!` may be called multiple times
per edge, depending on the traversal algorithm, for a function that operates on the first occurrence
only, use [`newvisitfn!`](@ref). For parallel algorithms, the thread ID or the CPU ID will be passed
in `t`.
"""
@inline visitfn!(::TraversalState, u, v) = true
@inline visitfn!(s::TraversalState, u, v, t::Integer) = visitfn!(s, u, v)

"""
    postvisitfn!(state, u)
    postvisitfn!(state, u, t)

Modify [`TraversalState`](@ref) `state` after having examined all neighbors of vertex `u`,
and return `true` if successful; `false` otherwise. For parallel algorithms, the thread ID or the
CPU ID will be passed in `t`.
"""
@inline postvisitfn!(::TraversalState, u) = true
@inline postvisitfn!(s::TraversalState, u, t::Integer) = postvisitfn!(s, u)

"""
    postlevelfn!(state)

Modify [`TraversalState`](@ref) `state` before moving to the next vertex in the traversal algorithm,
and return `true` if successful; `false` otherwise.
"""
@inline postlevelfn!(::TraversalState) = true

##############
# functions common to both BreadthFirst and DepthFirst
##############
"""
    traverse_graph!(g, ss, alg, state)

Traverse a graph `g` from source vertex/vertices `ss` keeping track of `state`. Return `true` if
traversal finished normally; `false` if one of the visit functions returned `false`.
"""
function traverse_graph! end

struct VisitState{T<:Integer} <: TraversalState
    visited::Vector{T}
end

@inline function initfn!(s::VisitState, u)
    push!(s.visited, u)
    return true
end

# note: since `newvisitfn!(s, u, v, t)` defaults to calling `newvisitfn!(s, u, v)`, this function
# by default creates the necessary visitor functions for parallel traversals.
@inline function newvisitfn!(s::VisitState, u, v)
    push!(s.visited, v)
    return true
end

"""
    visited_vertices(g, ss, alg)

Return a vector representing the vertices of `g` visited in order by [`TraversalAlgorithm`](@ref) `alg`
starting at vertex/vertices `ss`.
"""
function visited_vertices(
    g::AbstractGraph{U},
    ss,
    alg::TraversalAlgorithm
    ) where U<:Integer

    v = Vector{U}()
    sizehint!(v, nv(g))  # actually just the largest connected component, but we'll use this.
    state = VisitState(v)
    traverse_graph!(g, ss, alg, state)

    return state.visited
end

mutable struct ParentState{T<:Integer} <: TraversalState
    parents::Vector{T}
end

# note: since `newvisitfn!(s, u, v, t)` defaults to calling `newvisitfn!(s, u, v)`, this function
# by default creates the necessary visitor functions for parallel traversals.
@inline function newvisitfn!(s::ParentState, u, v) 
    s.parents[v] = u
    return true
end

"""
    parents(g, ss, alg)

Return a vector of parent vertices indexed by vertex using [`TraversalAlgorithm`](@ref) `alg` starting with
vertex/vertices `ss`. 

### Performance
This implementation is designed to perform well on large graphs. There are
implementations which are marginally faster in practice for smaller graphs,
but the performance improvements using this implementation on large graphs
can be significant.
"""
function parents(g::AbstractGraph{T}, ss, alg::TraversalAlgorithm) where T
    parents = zeros(T, nv(g))
    state = ParentState(parents)

    traverse_graph!(g, ss, alg, state)
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
    tree(g, ss, alg)

Return a directed acyclic graph based on traversal of the graph `g` starting with source vertex/vertices
`ss` using algorithm `alg`.
"""
tree(g::AbstractGraph, ss, alg::TraversalAlgorithm) = tree(parents(g, ss, alg))

"""
    distances(s::TraversalState)

Return a vector filled with the distances previously calculated and stored in
[`TraversalState`](@ref) `s`. Unreachable vertices are indicated by a distance
of `typemax(eltype(distances(s)))`.
"""
@inline distances(s::TraversalState) = s.distances

mutable struct DistanceState{T<:Integer} <: TraversalState
    distances::Vector{T}
    n_level::T
end

@inline function initfn!(s::DistanceState{T}, u) where T 
    s.distances[u] = zero(T)
    return true
end
@inline function newvisitfn!(s::DistanceState, u, v) 
    s.distances[v] = s.n_level
    return true
end
@inline function postlevelfn!(s::DistanceState{T}) where T
    s.n_level += one(T)
    return true
end

"""
    distances(g::AbstractGraph{T}, ss, alg=BreadthFirst())

Return a vector filled with the geodesic distances of vertices in  `g` from
source/sources `ss`. If `ss` is a collection of vertices each element should
be unique. For vertices unreachable from any vertex in `ss` the distance is
`typemax(T)`.
"""
function distances(g::AbstractGraph{T}, s, alg::TraversalAlgorithm=BreadthFirst()) where T
    state = DistanceState(fill(typemax(T), nv(g)), one(T))
    traverse_graph!(g, s, alg, state) || throw(TraversalError())
    return distances(state)
end

mutable struct PathState{T<:Integer} <: TraversalState
    u::T
    v::T
    exclude_vertices::Vector{T}
    vertices_in_exclude::Bool # set to true if the source or dest are in excludes.
end

@inline function preinitfn!(s::PathState, visited)
    visited[s.exclude_vertices] .= true
    s.vertices_in_exclude = visited[s.u] | visited[s.v]
    return !s.vertices_in_exclude
end
@inline newvisitfn!(s::PathState, u, v) = s.v != v 

"""
    has_path(g::AbstractGraph, u, v, alg; exclude_vertices=Vector())

Return `true` if there is a path from `u` to `v` in `g` (while avoiding vertices in
`exclude_vertices`) or `u == v`. Return false if there is no such path or if `u` or `v`
is in `exclude_vertices`. 


### Performance Notes
sorting `exclude_vertices` prior to calling the function may result in improved performance.
""" 
function has_path(g::AbstractGraph{T}, u::Integer, v::Integer, alg::TraversalAlgorithm=BreadthFirst(); exclude_vertices=Vector{T}()) where {T}
    u == v && return true
    state = PathState(T(u), T(v), T.(exclude_vertices), false)
    result = traverse_graph!(g, u, alg, state)
    # if traverse_graph is false, check the shortcircuit val.
    result && return false
    return !state.vertices_in_exclude
end


include("breadthfirst.jl")
include("threadedbreadthfirst.jl")
include("bipartition.jl")
include("depthfirst.jl")
include("diffusion.jl")
include("greedy_color.jl")
include("threaded_greedy_color.jl")
include("maxadjvisit.jl")
include("randomwalks.jl")

# TODO 2.0.0: uncomment this
# export TraversalError
# export tree, parents, visited_vertices, dists, distances, has_path
# export BreadthFirst
# export ThreadedBreadthFirst
# export is_bipartite, bipartite_map
# export DepthFirst, is_cyclic, topological_sort, CycleError 
# export randomwalk, self_avoiding_walk, non_backtracking_randomwalk
# export diffusion, diffusion_rate
# export FixedColoring, RandomColoring, DegreeColoring, greedy_color
# export mincut, maximum_adjacency_visit
end #module
