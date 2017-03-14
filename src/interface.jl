# This file contans the common interface for LightGraphs.

_NI(m) = error("Not implemented: $m")

"""A type representing a single edge between two vertices of a graph."""
abstract AbstractEdge

"""A type representing an edge iterator"""
abstract AbstractEdgeIter

"""An abstract type representing a graph."""
abstract AbstractGraph


@traitdef IsDirected{AbstractGraph}
@traitimpl IsDirected{G} <- is_directed(G)


#
# Interface for AbstractEdges
#

"""Return source of an edge."""
src(e::AbstractEdge) = _NI("src")

"""Return destination of an edge."""
dst(e::AbstractEdge) = _NI("dst")

Pair(e::AbstractEdge) = _NI("Pair")
Tuple(e::AbstractEdge) = _NI("Tuple")

reverse(e::AbstractEdge) = _NI("reverse")

==(e1::AbstractEdge, e2::AbstractEdge) = _NI("==")


#
# Interface for AbstractGraphs
#
"""Return the type of a graph's edge"""
edgetype(g::AbstractGraph) = _NI("edgetype")

"""Return the number of vertices in `g`."""
nv(g::AbstractGraph) = _NI("nv")

"""Return the number of edges in `g`."""
ne(g::AbstractGraph) = _NI("ne")

"""Return the vertices of a graph."""
vertices(g::AbstractGraph) = _NI("vertices")

"""Return an iterator to the edges of a graph.
The returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.
"""
edges(g::AbstractGraph) = _NI("edges")

is_directed(g::AbstractGraph) = _NI("is_directed")
is_directed{T<:AbstractGraph}(::Type{T}) = _NI("is_directed")
"""Add a new vertex to the graph `g`.
Returns true if the vertex was added successfully, false otherwise.
"""
add_vertex!(g::AbstractGraph) = _NI("add_vertex!")

"""
Add a new edge `e` to `g`.
Will return false if add fails (e.g., if vertices are not in the graph), true otherwise.
"""
add_edge!(g::AbstractGraph, e::AbstractEdge) = _NI("add_edge!")

"""
Remove the vertex `v` from graph `g`.
Returns false if removal fails (e.g., if vertex is not in the graph), true otherwise.
"""
rem_vertex!(g::AbstractGraph, v::Int) = _NI("rem_vertex!")

"""
Remove the edge `e` from `g`
Returns false if edge removal fails (e.g., if edge does not exist), true otherwise.
"""
rem_edge!(g::AbstractGraph, e::AbstractEdge) = _NI("rem_edge!")

"""Return true if `v` is a vertex of `g`."""
has_vertex(g::AbstractGraph, v::Int) = _NI("has_vertex")

"""Return true if the graph `g` has an edge `e`."""
has_edge(g::AbstractGraph, e::AbstractEdge) = _NI("has_edge")

"""
Return a list of all neighbors connected to vertex `v` by an incoming edge.
NOTE: returns a reference, not a copy. Do not modify result.
"""
in_neighbors(g::AbstractGraph, v::Int) = _NI("in_neighbors")

"""
Return a list of all neighbors connected to vertex `v` by an outgoing edge.
NOTE: returns a reference, not a copy. Do not modify result.
"""
out_neighbors(g::AbstractGraph, v::Int) = _NI("out_neighbors")
