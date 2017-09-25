# This file contans the common interface for LightGraphs.

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
"""
src(e::AbstractEdge) = _NI("src")

"""
    dst(e)

Return the destination vertex of edge `e`.
"""
dst(e::AbstractEdge) = _NI("dst")

Pair(e::AbstractEdge) = _NI("Pair")
Tuple(e::AbstractEdge) = _NI("Tuple")

"""
    reverse(e)

Create a new edge from `e` with source and destination vertices reversed.
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
"""
nv(g::AbstractGraph) = _NI("nv")

"""
    ne(g)

Return the number of edges in `g`.
"""
ne(g::AbstractGraph) = _NI("ne")

"""
    vertices(g)

Return (an iterator to or collection of) the vertices of a graph.

### Implementation Notes
A returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.

"""
vertices(g::AbstractGraph) = _NI("vertices")

"""
    edges(g)

Return (an iterator to or collection of) the edges of a graph.
For `AbstractSimpleGraph`s it returns a [`SimpleEdgeIter`](@ref).
The expressions `e in edges(g)` and `e ∈ edges(ga)` evaluate as
calls to [`has_edge`](@ref).

### Implementation Notes
A returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.
"""
edges(g) = _NI("edges")

"""
    is_directed(g)

Return true if the graph is a directed graph; false otherwise.
"""
is_directed(g) = _NI("is_directed")
is_directed(::Type{T}) where T = _NI("is_directed")
"""
    add_vertex!(g)

Add a new vertex to the graph `g`.
Return true if the vertex was added successfully, false otherwise.
"""
add_vertex!(x) = _NI("add_vertex!")

"""
    add_edge!(g, e)

Add a new edge `e` to `g`. Return false if add fails
(e.g., if vertices are not in the graph, or edge already exists), true otherwise.
"""
add_edge!(x, e) = _NI("add_edge!")


"""
add_edges!(g, es)

Add new edges `e in es` to `g`. Return true if any new edges are added.
Implicitly adds new vertices needed.
"""
function add_edges!(g, es)
    modified = false
    for e in es
        n = max(dst(e), src(e))
        if n > nv(g) 
            add_vertices!(g, n - nv(g))
        end
        modified = add_edge!(g, e) || modified
    end
    modified
end


"""
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`. Return false if removal fails
(e.g., if vertex is not in the graph), true otherwise.
"""
rem_vertex!(x, v) = _NI("rem_vertex!")

"""
    rem_edge!(g, e)

Remove the edge `e` from `g`. Return false if edge removal fails
(e.g., if edge does not exist), true otherwise.
"""
rem_edge!(x, e) = _NI("rem_edge!")

"""
    has_vertex(g, v)

Return true if `v` is a vertex of `g`.
"""
has_vertex(x, v) = _NI("has_vertex")

"""
    has_edge(g, e)
    e ∈ edges(g)

Return true if the graph `g` has an edge `e`. 
The expressions `e in edges(g)` and `e ∈ edges(ga)` evaluate as
calls to `has_edge`, c.f. [`edges`](@ref).
"""
has_edge(x, e) = _NI("has_edge")

"""
    in_neighbors(g, v)

Return a list of all neighbors connected to vertex `v` by an incoming edge.

### Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
in_neighbors(x, v) = _NI("in_neighbors")

"""
    out_neighbors(g, v)

Return a list of all neighbors connected to vertex `v` by an outgoing edge.

# Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
out_neighbors(x, v) = _NI("out_neighbors")

"""
    zero(g)

Return a zero-vertex, zero-edge version of the same type of graph as `g`.
"""
zero(g::AbstractGraph) = _NI("zero")
