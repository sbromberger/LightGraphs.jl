abstract AbstractPathState

"""
Abstract Graph type
guarantees:
    vertices are integers in 1:nv(g)
    edges are pair of vertices

functions to implement:
    basic constructors
    edges(g) returns a set/interators on edges
    nv(g)
    ne(g)
    has_edge(g, e)
    fadj(g)
    copy(g, h)
    add_vertex!(g)
    rem_vertex!(g, v)
    add_edge!(g, e)
    rem_edge!(g, e)
"""
abstract SimpleGraph

"""
Abstract undirected graph type
"""
abstract Graph <: SimpleGraph

"""
Abstract directed graph type
"""
abstract DiGraph <: SimpleGraph

####### Required interface for concrete types ########################

"""The number of vertices in `g`."""
nv(g::SimpleGraph) = nothing

"""The number of edges in `g`."""
ne(g::SimpleGraph) = nothing

"""Returns an edge set or an iterator to the edges in `g`."""
edges(g::SimpleGraph) = nothing


"""
Return true if the graph `g` has the edge `e`.
Also supports the from `has_edge(g, src, dst)`
"""
has_edge(g::SimpleGraph, e::Edge) = nothing

"""Returns the forward adjacency list of a graph.

The Array, where each vertex the Array of destinations for each of the edges eminating from that vertex.
This is equivalent to:

    fadj = [Int[] for _ in vertices(g)]
    for e in edges(g)
        push!(fadj[src(e)], dst(e))
    end
    fadj

For most graphs types this is pre-calculated, and in any case any tipe that inherits from
SimpleGraph has to guarantee O(1) time for the adjlist construction.

The optional second argument take the `v`th vertex adjacency list, that is:

    fadj(g, v::Int) == fadj(g)[v]
"""
fadj(g::SimpleGraph) = nothing

"""Returns the backwards adjacency list of a graph.
For each vertex the Array of `dst` for each edge eminating from that vertex."""
badj(g::SimpleGraph) = nothing

"Returns `true` if `g` is a directed graph, `false` otherwise."
is_directed(g::SimpleGraph) = nothing

"""Add a new edge `e` to `g`.
Also the form  add_edge!(g, src, dst) is supported.

Note: An exception will be raised if the edge is already in the graph
or if the vertex is not contained in the graph.
"""
add_edge!(g::SimpleGraph, e::Edge) = nothing

"""Remove edge `e` from `g`.
Also the form  rem_edge!(g, src, dst) is supported.

Note: An exception will be raised if the edge is already in the graph
or if the vertex is not contained in the graph.
"""
rem_edge!(g::SimpleGraph, e::Edge) = nothing

"""Add a new vertex to `g`.
"""
add_vertex!(g::SimpleGraph, e::Edge) = nothing

"""returns a copy of `g`."""
copy{G<:SimpleGraph}(g::G) = nothing

########## Constructors for the abstract types #######################

Base.call(::Type{Graph}, n::Int) = LightGraph(n)
Base.call(::Type{Graph}) = LightGraph()
Base.call{T<:Real}(::Type{Graph}, adjmx::AbstractMatrix{T}) = LightGraph(adjmx)
Base.call(::Type{Graph}, g::DiGraph) = LightGraph(g)

Base.call(::Type{DiGraph}, n::Int) = LightDiGraph(n)
Base.call(::Type{DiGraph}) = LightDiGraph()
Base.call{T<:Real}(::Type{DiGraph}, adjmx::SparseMatrixCSC{T}) = LightDiGraph(adjmx)
Base.call{T<:Real}(::Type{DiGraph}, adjmx::AbstractMatrix{T}) = LightDiGraph(adjmx)
Base.call(::Type{DiGraph}, g::Graph) = LightDiGraph(g)

############## Characterization of Graph vs DiGraph ##########################
"""Returns the adjacency list of a graph.
For each vertex the Array of `dst` for each edge eminating from that vertex.

NOTE: returns a reference, not a copy. Do not modify result.
"""
adj(g::Graph) = fadj(g)
adj(g::Graph, v::Int) = fadj(g, v)

is_directed(g::Graph) = false
is_directed(g::DiGraph) = true

############################################################################

"""A type representing a single edge between two vertices of a graph."""
typealias Edge Pair{Int,Int}

"""Return source of an edge."""
src(e::Edge) = e.first
"""Return destination of an edge."""
dst(e::Edge) = e.second

==(e1::Edge, e2::Edge) = (e1.first == e2.first && e1.second == e2.second)

function show(io::IO, e::Edge)
    print(io, "edge $(e.first) - $(e.second)")
end

"""Return the vertices of a graph."""
vertices(g::SimpleGraph) = 1:nv(g)

fadj(g::SimpleGraph, v::Int) = fadj(g)[v]
badj(g::SimpleGraph, v::Int) = badj(g)[v]

"""Returns true if all of the vertices and edges of `g` are contained in `h`."""
function issubset{T<:SimpleGraph}(g::T, h::T)
    return nv(g) <= nv(h) && issubset(edges(g), edges(h))
end

"""Add `n` new vertices to the graph `g`."""
function add_vertices!(g::SimpleGraph, n::Integer)
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end

has_edge(g::SimpleGraph, src::Int, dst::Int) = has_edge(g, Edge(src,dst))

"""Return an Array of the edges in `g` that arrive at vertex `v`."""
in_edges(g::SimpleGraph, v::Int) = [Edge(x,v) for x in badj(g,v)]

"""Return an Array of the edges in `g` that emanate from vertex `v`."""
out_edges(g::SimpleGraph, v::Int) = [Edge(v,x) for x in fadj(g,v)]

"""Return true if `v` is a vertex of `g`."""
has_vertex(g::SimpleGraph, v::Int) = v <= nv(g)

add_edge!(g::SimpleGraph, src::Int, dst::Int) = add_edge!(g, Edge(src, dst))
rem_edge!(g::SimpleGraph, src::Int, dst::Int) = rem_edge!(g, Edge(src,dst))

"""Return the number of edges which start at vertex `v`."""
indegree(g::SimpleGraph, v::Int) = length(badj(g,v))
"""Return the number of edges which end at vertex `v`."""
outdegree(g::SimpleGraph, v::Int) = length(fadj(g,v))

indegree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
degree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]

"""Produces a histogram of degree values across all vertices for the graph `g`.
The number of histogram buckets is based on the number of vertices in `g`.
"""
degree_histogram(g::SimpleGraph) = (hist(degree(g), 0:nv(g)-1)[2])

"Return the maxium `outdegree` of vertices in `g`."
Δout(g) = noallocextreme(outdegree,(>), typemin(Int), g)
"Return the minimum `outdegree` of vertices in `g`."
δout(g) = noallocextreme(outdegree,(<), typemax(Int), g)
"Return the maximum `indegree` of vertices in `g`."
δin(g)  = noallocextreme(indegree,(<), typemax(Int), g)
"Return the minimum `indegree` of vertices in `g`."
Δin(g)  = noallocextreme(indegree,(>), typemin(Int), g)
"Return the minimum `degree` of vertices in `g`."
δ(g)    = noallocextreme(degree,(<), typemax(Int), g)
"Return the maximum `degree` of vertices in `g`."
Δ(g)    = noallocextreme(degree,(>), typemin(Int), g)

"computes the extreme value of `[f(g,i) for i=i:nv(g)]` without gathering them all"
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

"Returns a list of all neighbors connected to vertex `v` by an incoming edge."
in_neighbors(g::SimpleGraph, v::Int) = badj(g,v)
"Returns a list of all neighbors connected to vertex `v` by an outgoing edge."
out_neighbors(g::SimpleGraph, v::Int) = fadj(g,v)

"""Returns a list of all neighbors of vertex `v` in `g`.

For DiGraphs, this is equivalent to `out_neighbors(g, v)`.
"""
neighbors(g::SimpleGraph, v::Int) = out_neighbors(g, v)

"Returns the neighbors common to vertices `u` and `v` in `g`."
common_neighbors(g::SimpleGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))

"Returns true if `g` is has any self loops."
has_self_loop(g::SimpleGraph) = any(v->has_edge(g, v, v), vertices(g))

function show(io::IO, g::SimpleGraph)
    isdir = is_directed(g) ? "directed" : "undirected"
    if nv(g) == 0
        print(io, "empty $isdir graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} $isdir graph")
    end
end

"""Check for graph equality"""
function ==(g::Graph, h::Graph)
    gdigraph = DiGraph(g)
    hdigraph = DiGraph(h)
    return (gdigraph == hdigraph)
end
function ==(g::DiGraph, h::DiGraph)
    return (vertices(g) == vertices(h)) && (edges(g) == edges(h))
end


"""Return the number of edges (both ingoing and outgoing) from the vertex `v`."""
degree(g::Graph, v::Int) = indegree(g,v)
degree(g::DiGraph, v::Int) = indegree(g,v) + outdegree(g,v)

"Returns all the vertices which share an edge with `v`."
all_neighbors(g::DiGraph, v::Int) = union(in_neighbors(g,v), out_neighbors(g,v))

doc"""Density is defined as the ratio of the number of actual edges to the
number of possible edges. This is $|v| |v-1|$ for directed graphs and
$(|v| |v-1|) / 2$ for undirected graphs.
"""
density(g::Graph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
density(g::DiGraph) = ne(g) / (nv(g) * (nv(g)-1))
