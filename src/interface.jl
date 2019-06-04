# This file contans the common interface for LightGraphs.
# TODO 0.7: reevaluate use of errors here.

_NI(m) = error("Not implemented: $m")

"""
    AbstractEdge

An abstract type representing a single edge between two vertices of a graph.
"""
abstract type AbstractEdge{T} end

"""
    AbstractEdgeIter

An abstract type representing an edge iterator.
"""
abstract type AbstractEdgeIter end

"""
    AbstractGraph

An abstract type representing a graph.
"""
abstract type AbstractGraph{T} end


@traitdef IsDirected{G<:AbstractGraph}
@traitimpl IsDirected{G} <- is_directed(G)


#
# Interface for AbstractEdges
#

"""
    src(e)

Return the source vertex of edge `e`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2);

julia> src(first(edges(g)))
1
```
"""
src(e::AbstractEdge) = _NI("src")

"""
    dst(e)

Return the destination vertex of edge `e`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2);

julia> dst(first(edges(g)))
2
```
"""
dst(e::AbstractEdge) = _NI("dst")

Pair(e::AbstractEdge) = _NI("Pair")
Tuple(e::AbstractEdge) = _NI("Tuple")

"""
    reverse(e)

Create a new edge from `e` with source and destination vertices reversed.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleDiGraph(2);

julia> add_edge!(g, 1, 2);

julia> reverse(first(edges(g)))
Edge 2 => 1
```
"""
reverse(e::AbstractEdge) = _NI("reverse")

==(e1::AbstractEdge, e2::AbstractEdge) = _NI("==")


#
# Interface for AbstractGraphs
#
"""
    edgetype(g)

Return the type of graph `g`'s edge
"""
edgetype(g::AbstractGraph) = _NI("edgetype")

"""
    eltype(g)

Return the type of the graph's vertices (must be <: Integer)
"""
eltype(g::AbstractGraph) = _NI("eltype")

"""
    nv(g)

Return the number of vertices in `g`.

# Examples
```jldoctest
julia> using LightGraphs

julia> nv(SimpleGraph(3))
3
```
"""
nv(g::AbstractGraph) = _NI("nv")

"""
    ne(g)

Return the number of edges in `g`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = PathGraph(3);

julia> ne(g)
2
```
"""
ne(g::AbstractGraph) = _NI("ne")

"""
    vertices(g)

Return (an iterator to or collection of) the vertices of a graph.

### Implementation Notes
A returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.

# Examples
```jldoctest
julia> using LightGraphs

julia> collect(vertices(SimpleGraph(4)))
4-element Array{Int64,1}:
 1
 2
 3
 4
```
"""
vertices(g::AbstractGraph) = _NI("vertices")

"""
    edges(g)

Return (an iterator to or collection of) the edges of a graph.
For `AbstractSimpleGraph`s it returns a `SimpleEdgeIter`.
The expressions `e in edges(g)` and `e ∈ edges(ga)` evaluate as
calls to [`has_edge`](@ref).

### Implementation Notes
A returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = PathGraph(3);

julia> collect(edges(g))
2-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
```
"""
edges(g) = _NI("edges")

"""
    is_directed(G)

Return `true` if the graph type `G` is a directed graph; `false` otherwise.
New graph types must implement `is_directed(::Type{<:G})`.
The method can also be called with `is_directed(g::G)`
# Examples
```jldoctest
julia> using LightGraphs

julia> is_directed(SimpleGraph(2))
false

julia> is_directed(SimpleGraph)
false

julia> is_directed(SimpleDiGraph(2))
true
```
"""
is_directed(::G) where {G} = is_directed(G)
is_directed(::Type{T}) where T = _NI("is_directed")

"""
    has_vertex(g, v)

Return true if `v` is a vertex of `g`.

# Examples
```jldoctest
julia> using LightGraphs

julia> has_vertex(SimpleGraph(2), 1)
true

julia> has_vertex(SimpleGraph(2), 3)
false
```
"""
has_vertex(x, v) = _NI("has_vertex")

"""
    has_edge(g, s, d)

Return true if the graph `g` has an edge from node `s` to node `d`.

An optional `has_edge(g, e)` can be implemented to check if an edge belongs
to a graph, including any data other than source and destination node.

`e ∈ edges(g)` or `e ∈ edges(g)` evaluate as
calls to `has_edge`, c.f. [`edges`](@ref).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleDiGraph(2);

julia> add_edge!(g, 1, 2);

julia> has_edge(g, 1, 2)
true

julia> has_edge(g, 2, 1)
false
```
"""
has_edge(g, s, d) = _NI("has_edge")
has_edge(g, e) = has_edge(g, src(e), dst(e))

"""
    inneighbors(g, v)

Return a list of all neighbors connected to vertex `v` by an incoming edge.

### Implementation Notes
Returns a reference, not a copy. Do not modify result.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> inneighbors(g, 4)
2-element Array{Int64,1}:
 3
 5
```
"""
inneighbors(x, v) = _NI("inneighbors")

"""
    outneighbors(g, v)

Return a list of all neighbors connected to vertex `v` by an outgoing edge.

# Implementation Notes
Returns a reference, not a copy. Do not modify result.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> outneighbors(g, 4)
1-element Array{Int64,1}:
 5
```
"""
outneighbors(x, v) = _NI("outneighbors")

"""
    zero(g)

Return a zero-vertex, zero-edge version of the same type of graph as `g`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> zero(g)
{0, 0} directed simple Int64 graph
```
"""
zero(g::AbstractGraph) = _NI("zero")
