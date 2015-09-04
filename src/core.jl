abstract AbstractPathState

abstract SimpleGraph
abstract SimpleAdjGraph<:SimpleGraph
abstract SimpleSparseGraph<:SimpleGraph

if VERSION < v"0.4.0-dev+818"
    immutable Pair{T1,T2}
        first::T1
        second::T2
    end

end

if VERSION < v"0.4.0-dev+4103"
    reverse(p::Pair) = Pair(p.second, p.first)
end

"""A type representing a single edge between two vertices of a graph."""
typealias Edge Pair{Int,Int}

"""Return source of an edge."""
src(e::Edge) = e.first
"""Return destination of an edge."""
dst(e::Edge) = e.second

@deprecate rev(e::Edge) reverse(e)

==(e1::Edge, e2::Edge) = (e1.first == e2.first && e1.second == e2.second)

function show(io::IO, e::Edge)
    print(io, "edge $(e.first) - $(e.second)")
end

"""A type representing an undirected graph."""
type Graph<:SimpleAdjGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

"""A type representing a directed graph."""
type DiGraph<:SimpleAdjGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

type SparseGraph<:SimpleSparseGraph
    edges::Set{Edge}
    fm::SparseMatrixCSC{Bool, Int}
    bm::SparseMatrixCSC{Bool, Int}
end

SparseGraph(n) = SparseGraph(Set{Edge}(), spzeros(Float64,n,n), spzeros(Float64,n,n))

function SparseGraph(g::Graph)
    fm = adjacency_matrix(g,:out, Bool)
    return SparseGraph(g.edges, fm, fm')
end

type SparseDiGraph<:SimpleSparseGraph
    edges::Set{Edge}
    fm::SparseMatrixCSC{Bool, Int}
    bm::SparseMatrixCSC{Bool, Int}
end

SparseDiGraph(n::Int) = SparseDiGraph(Set{Edge}(), spzeros(Float64,n,n), spzeros(Float64,n,n))

function SparseDiGraph(g::DiGraph)
    fm = adjacency_matrix(g,:out, Bool)
    return SparseDiGraph(g.edges, fm, fm')
end

# typealias SimpleGraph Union(Graph, DiGraph)


"""Return the vertices of a graph."""
vertices(g::SimpleGraph) = g.vertices
vertices(g::SimpleSparseGraph) = 1:size(g.fm, 1)

"""Return the edges of a graph."""
edges(g::SimpleGraph) = g.edges


"""Returns the forward adjacency list of a graph.

The Array, where each vertex the Array of destinations for each of the edges eminating from that vertex.
This is equivalent to:

    fadj = [Int[] for _ in vertices(g)]
    for e in edges(g)
        push!(fadj[src(e)], dst(e))
    end
    fadj

For most graphs types this is pre-calculated.

The optional second argument take the `v`th vertex adjacency list, that is:

    fadj(g, v::Int) == fadj(g)[v]
"""
fadj(g::SimpleGraph) = g.fadjlist
fadj(g::SimpleGraph, v::Int) = g.fadjlist[v]

_column(a::SparseMatrixCSC, i::Integer) = sub(a.rowval, a.colptr[i]:a.colptr[i+1]-1)

fadj(g::SimpleSparseGraph, v::Int) = _column(g.fm, v)
fadj(g::SimpleSparseGraph) = [fadj(g,i) for i in 1:nv(g)]

"""Returns the backwards adjacency list of a graph.
For each vertex the Array of `dst` for each edge eminating from that vertex."""
badj(g::SimpleGraph) = g.badjlist
badj(g::SimpleGraph, v::Int) = g.badjlist[v]

badj(g::SimpleSparseGraph, v::Int) = _column(g.bm, v)
badj(g::SimpleSparseGraph) = [badj(g,i) for i in vertices(g)]


"""Returns true if all of the vertices and edges of `g` are contained in `h`."""
function issubset{T<:SimpleGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) && issubset(edges(g), edges(h))
end

"""Add a new vertex to the graph `g`."""
function add_vertex!(g::SimpleGraph)
    n = length(vertices(g)) + 1
    g.vertices = 1:n
    push!(g.badjlist, Int[])
    push!(g.fadjlist, Int[])

    return n
end

"""Add `n` new vertices to the graph `g`."""
function add_vertices!(g::SimpleGraph, n::Integer)
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end

"""Return true if the graph `g` has an edge from `src` to `dst`."""
has_edge(g::SimpleGraph, src::Int, dst::Int) = has_edge(g,Edge(src,dst))

"""Return an Array of the edges in `g` that arrive at vertex `v`."""
in_edges(g::SimpleGraph, v::Int) = [Edge(x,v) for x in badj(g,v)]
"""Return an Array of the edges in `g` that emanate from vertex `v`."""
out_edges(g::SimpleGraph, v::Int) = [Edge(v,x) for x in fadj(g,v)]

"""Return true if `v` is a vertex of `g`."""
has_vertex(g::SimpleGraph, v::Int) = v in vertices(g)

"""The number of vertices in `g`."""
nv(g::SimpleGraph) = length(vertices(g))
nv(g::SimpleSparseGraph) = size(g.fm,1)

"""The number of edges in `g`."""
ne(g::SimpleGraph) = length(edges(g))

"""Add a new edge to `g` from `src` to `dst`.

Note: An exception will be raised if the edge is already in the graph
or if the vertex is not contained in the graph.
"""
function add_edge!(g::SimpleGraph, e::Edge)
    has_edge(g,e) && error("Edge $e already in graph")
    (has_vertex(g,src(e)) && has_vertex(g,dst(e))) || throw(BoundsError())
    unsafe_add_edge!(g,e)
end

function add_edge!(g::SparseDiGraph, e::Edge)
    g.fm[src(e),dst(e)] = true
    g.bm[dst(e),src(e)] = true
    push!(g.edges, e)
end

function add_edge!(g::SparseGraph, e::Edge)
    g.fm[src(e),dst(e)] = true
    g.fm[dst(e),src(e)] = true
    g.bm[src(e),dst(e)] = true
    g.bm[dst(e),src(e)] = true
    push!(g.edges, e)
end


add_edge!(g::SimpleGraph, src::Int, dst::Int) = add_edge!(g, Edge(src,dst))

"""Remove the edge from `src` to `dst`.

Note: An exception will be raised if the edge is not in the graph.
"""
rem_edge!(g::SimpleGraph, src::Int, dst::Int) = rem_edge!(g, Edge(src,dst))

"""Return the number of edges which start at vertex `v`."""
indegree(g::SimpleGraph, v::Int) = length(badj(g,v))
"""Return the number of edges which end at vertex `v`."""
outdegree(g::SimpleGraph, v::Int) = length(fadj(g,v))

indegree(g::SimpleSparseGraph, v::Int) = g.bm.colptr[v+1]-g.fm.colptr[v]
indegree(g::SimpleSparseGraph, v::AbstractVector{Int}) = [indegree(g,x) for x in v]
indegree(g::SimpleSparseGraph) = diff(g.bm.colptr)
outdegree(g::SimpleSparseGraph, v::Int) = g.fm.colptr[v+1]-g.bm.colptr[v]
outdegree(g::SimpleSparseGraph, v::AbstractVector{Int}) = [outdegree(g,x) for x in v]
outdegree(g::SimpleSparseGraph) = diff(g.fm.colptr)

indegree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
degree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]

Δout(g::SimpleSparseGraph) = maximum(outdegree(g))
δout(g::SimpleSparseGraph) = minimum(outdegree(g))
Δin(g::SimpleSparseGraph) = maximum(indegree(g))
δin(g::SimpleSparseGraph) = minimum(indegree(g))
Δ(g::SimpleSparseGraph) = maximum(degree(g))
δ(g::SimpleSparseGraph) = minimum(degree(g))


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

"""Produces a histogram of degree values across all vertices for the graph `g`.
The number of histogram buckets is based on the number of vertices in `g`.
"""
degree_histogram(g::SimpleGraph) = (hist(degree(g), 0:nv(g)-1)[2])


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

function copy{T<:SimpleGraph}(g::T)
    return T(g.vertices,copy(g.edges),deepcopy(g.fadjlist),deepcopy(g.badjlist))
end

"Returns true if `g` is has any self loops."
has_self_loop(g::SimpleGraph) = any(v->has_edge(g, v, v), vertices(g))
