_NI(m...) = error("Not implementedxxx")

abstract AbstractPathState
# modified from http://stackoverflow.com/questions/25678112/insert-item-into-a-sorted-list-with-julia-with-and-without-duplicates
# returns true if insert succeeded, false if it was a duplicate
_insert_and_dedup!(v::Vector{Int}, x::Int) = isempty(splice!(v, searchsorted(v,x), x))

"""A type representing a single edge between two vertices of a graph."""
abstract AbstractEdge

"""An abstract type representing a graph."""
abstract AbstractLightGraph
abstract AbstractGraph <: AbstractLightGraph
abstract AbstractDiGraph <: AbstractLightGraph

"""Return the type of a graph's edge"""
edgetype(g::AbstractLightGraph) = _NI()

"""Return source of an edge."""
src(e::AbstractEdge) = _NI()
"""Return destination of an edge."""
dst(e::AbstractEdge) = _NI()

# The following functions should be implemented for each edge type.
Pair(e::AbstractEdge) = _NI()
Tuple(e::AbstractEdge) = _NI()
reverse(e::AbstractEdge) = _NI()
==(e1::AbstractEdge, e2::AbstractEdge) = _NI()

is_ordered(e::AbstractEdge) = src(e) <= dst(e)


"""Return the vertices of a graph."""
vertices(g::AbstractLightGraph) = _NI()

"""Return an iterator to the edges of a graph.
The returned iterator is valid for one pass over the edges, and is invalidated by changes to `g`.
"""
edges(g::AbstractLightGraph) = EdgeIter(g)

"""Returns the forward adjacency list of a graph.

The Array, where each vertex the Array of destinations for each of the edges eminating from that vertex.
This is equivalent to:

    fadj = [Vector{Int}() for _ in vertices(g)]
    for e in edges(g)
        push!(fadj[src(e)], dst(e))
    end
    fadj

For most graphs types this is pre-calculated.

The optional second argument take the `v`th vertex adjacency list, that is:

    fadj(g, v::Int) == fadj(g)[v]

NOTE: returns a reference, not a copy. Do not modify result.
"""
fadj(g::AbstractLightGraph) = _NI()
fadj(g::AbstractLightGraph, v::Int) = _NI()

badj(g::AbstractLightGraph) = _NI()
badj(g::AbstractLightGraph, v::Int) = _NI()

adj(g::AbstractLightGraph) = _NI()
adj(g::AbstractLightGraph, v::Int) = _NI()
"""Returns true if all of the vertices and edges of `g` are contained in `h`."""
issubset{T<:AbstractLightGraph}(g::T, h::T) = _NI()

is_directed(g::AbstractLightGraph) = _NI()

add_vertex!(g::AbstractLightGraph) = _NI()
"""Add `n` new vertices to the graph `g`. Returns true if all vertices
were added successfully, false otherwise."""
add_vertices!(g::AbstractLightGraph) = _NI()

"""Return true if the graph `g` has an edge from `u` to `v`."""
has_edge(g::AbstractLightGraph, u::Int, v::Int) = _NI()

"""
    in_edges(g, v)

Returns an Array of the edges in `g` that arrive at vertex `v`.
`v=dst(e)` for each returned edge `e`.
"""
in_edges(g::AbstractLightGraph, v::Int) = _NI()

"""
    out_edges(g, v)

Returns an Array of the edges in `g` that depart from vertex `v`.
`v = src(e)` for each returned edge `e`.
"""
out_edges(g::AbstractLightGraph, v::Int) = _NI()


"""Return true if `v` is a vertex of `g`."""
has_vertex(g::AbstractLightGraph, v::Int) = _NI()

"""
    nv(g)

The number of vertices in `g`.
"""
nv(g::AbstractLightGraph) = _NI()
"""
    ne(g)

The number of edges in `g`.
"""
ne(g::AbstractLightGraph) = _NI()

"""
    add_edge!(g, u, v)

Add a new edge to `g` from `u` to `v`.
Will return false if add fails (e.g., if vertices are not in the graph); true otherwise.
"""
add_edge!(g::AbstractLightGraph, u::Int, v::Int) = _NI()

"""
    rem_edge!(g, u, v)

Remove the edge from `u` to `v`.

Returns false if edge removal fails (e.g., if edge does not exist); true otherwise.
"""
rem_edge!(g::AbstractLightGraph, u::Int, v::Int) = _NI()

"""
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`.
This operation has to be performed carefully if one keeps external data structures indexed by
edges or vertices in the graph, since internally the removal is performed swapping the vertices `v`  and `n=nv(g)`,
and removing the vertex `n` from the graph.
After removal the vertices in the ` g` will be indexed by 1:n-1.
This is an O(k^2) operation, where `k` is the max of the degrees of vertices `v` and `n`.
Returns false if removal fails (e.g., if vertex is not in the graph); true otherwise.
"""
rem_vertex!(g::AbstractLightGraph, v::Int) = _NI()

"""Return the number of edges which end at vertex `v`."""
indegree(g::AbstractLightGraph, v::Int) = _NI()
"""Return the number of edges which start at vertex `v`."""
outdegree(g::AbstractLightGraph, v::Int) = _NI()


indegree(g::AbstractLightGraph, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::AbstractLightGraph, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
"""Return the number of edges (both ingoing and outgoing) from the vertex `v`."""
degree(g::AbstractLightGraph, v::Int) = _NI()

degree(g::AbstractLightGraph, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]

"Return the maximum `outdegree` of vertices in `g`."
Δout(g) = noallocextreme(outdegree,(>), typemin(Int), g)
"Return the minimum `outdegree` of vertices in `g`."
δout(g) = noallocextreme(outdegree,(<), typemax(Int), g)
"Return the maximum `indegree` of vertices in `g`."
Δin(g)  = noallocextreme(indegree,(>), typemin(Int), g)
"Return the minimum `indegree` of vertices in `g`."
δin(g)  = noallocextreme(indegree,(<), typemax(Int), g)
"Return the maximum `degree` of vertices in `g`."
Δ(g)    = noallocextreme(degree,(>), typemin(Int), g)
"Return the minimum `degree` of vertices in `g`."
δ(g)    = noallocextreme(degree,(<), typemax(Int), g)

"Computes the extreme value of `[f(g,i) for i=i:nv(g)]` without gathering them all"
function noallocextreme(f, comparison, initial, g)
    value = initial
    for i in 1:nv(g)
        funci = f(g, i)
        if comparison(funci, value)
            value = funci
        end
    end
    return value
end

"""
    degree_histogram(g)

Returns a `StatsBase.Histogram` of the degrees of vertices in `g`.
"""
degree_histogram(g::AbstractLightGraph) = fit(Histogram, degree(g))

"""Returns a list of all neighbors connected to vertex `v` by an incoming edge.

NOTE: returns a reference, not a copy. Do not modify result.
"""
in_neighbors(g::AbstractLightGraph, v::Int) = _NI()
"""Returns a list of all neighbors connected to vertex `v` by an outgoing edge.

NOTE: returns a reference, not a copy. Do not modify result.
"""
out_neighbors(g::AbstractLightGraph, v::Int) = _NI()

"""Returns a list of all neighbors of vertex `v` in `g`.

For DiGraphs, this is equivalent to `out_neighbors(g, v)`.

NOTE: returns a reference, not a copy. Do not modify result.
"""
neighbors(g::AbstractLightGraph, v::Int) = _NI()

"Returns the neighbors common to vertices `u` and `v` in `g`."
common_neighbors(g::AbstractLightGraph, u::Int, v::Int) = _NI()

all_neighbors(g::AbstractLightGraph) = _NI()

"Returns true if `g` has any self loops."
has_self_loops(g::AbstractLightGraph) = any(v->has_edge(g, v, v), vertices(g))

"Returns the number of self loops in `g`."
num_self_loops(g::AbstractLightGraph) = sum(v->has_edge(g, v, v), vertices(g))

density(g::AbstractLightGraph) = _NI()
