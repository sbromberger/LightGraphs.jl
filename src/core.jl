abstract AbstractPathState
# modified from http://stackoverflow.com/questions/25678112/insert-item-into-a-sorted-list-with-julia-with-and-without-duplicates
# returns true if insert succeeded, false if it was a duplicate
_insert_and_dedup!(v::Vector{Int}, x::Int) = isempty(splice!(v, searchsorted(v,x), x))

"""A type representing a single edge between two vertices of a graph."""
typealias Edge Pair{Int,Int}

@deprecate rev(e::Edge) reverse(e)

"""Return source of an edge."""
src(e::Edge) = e.first
"""Return destination of an edge."""
dst(e::Edge) = e.second

 is_ordered(e::Edge) = src(e) <= dst(e)

==(e1::Edge, e2::Edge) = (e1.first == e2.first && e1.second == e2.second)

"""A type representing an undirected graph."""
type Graph
    vertices::UnitRange{Int}
    ne::Int
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
end

"""A type representing a directed graph."""
type DiGraph
    vertices::UnitRange{Int}
    ne::Int
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

typealias SimpleGraph Union{Graph, DiGraph}


"""Return the vertices of a graph."""
vertices(g::SimpleGraph) = g.vertices

"""Return an iterator to the edges of a graph.
The returned iterator is valid for one pass over the edges, and is invalidated by changes to `g`.
"""
edges(g::SimpleGraph) = EdgeIter(g)

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
fadj(g::SimpleGraph) = g.fadjlist
fadj(g::SimpleGraph, v::Int) = g.fadjlist[v]

"""Returns true if all of the vertices and edges of `g` are contained in `h`."""
function issubset{T<:SimpleGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) && issubset(edges(g), edges(h))
end


"""Add `n` new vertices to the graph `g`. Returns true if all vertices
were added successfully, false otherwise."""
function add_vertices!(g::SimpleGraph, n::Integer)
    added = true
    for i = 1:n
        added &= add_vertex!(g)
    end
    return added
end

"""Return true if the graph `g` has an edge from `u` to `v`."""
has_edge(g::SimpleGraph, u::Int, v::Int) = has_edge(g, Edge(u, v))

"""
    in_edges(g, v)

Returns an Array of the edges in `g` that arrive at vertex `v`.
`v=dst(e)` for each returned edge `e`.
"""
in_edges(g::SimpleGraph, v::Int) = [Edge(x,v) for x in badj(g, v)]

"""
    out_edges(g, v)

Returns an Array of the edges in `g` that depart from vertex `v`.
`v = src(e)` for each returned edge `e`.
"""
out_edges(g::SimpleGraph, v::Int) = [Edge(v,x) for x in fadj(g,v)]


"""Return true if `v` is a vertex of `g`."""
has_vertex(g::SimpleGraph, v::Int) = v in vertices(g)

"""
    nv(g)

The number of vertices in `g`.
"""
nv(g::SimpleGraph) = length(vertices(g))
"""
    ne(g)

The number of edges in `g`.
"""
ne(g::SimpleGraph) = g.ne

"""
    add_edge!(g, u, v)

Add a new edge to `g` from `u` to `v`.
Will return false if add fails (e.g., if vertices are not in the graph); true otherwise.
"""
add_edge!(g::SimpleGraph, u::Int, v::Int) = add_edge!(g, Edge(u, v))

"""
    rem_edge!(g, u, v)

Remove the edge from `u` to `v`.

Returns false if edge removal fails (e.g., if edge does not exist); true otherwise.
"""
rem_edge!(g::SimpleGraph, u::Int, v::Int) = rem_edge!(g, Edge(u, v))

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
function rem_vertex!(g::SimpleGraph, v::Int)
    v in vertices(g) || return false
    n = nv(g)

    edgs = in_edges(g, v)
    for e in edgs
        rem_edge!(g, e)
    end
    neigs = copy(in_neighbors(g, n))
    for i in neigs
        rem_edge!(g, Edge(i, n))
    end
    if v != n
        for i in neigs
            add_edge!(g, Edge(i, v))
        end
    end

    if is_directed(g)
        edgs = out_edges(g, v)
        for e in edgs
            rem_edge!(g, e)
        end
        neigs = copy(out_neighbors(g, n))
        for i in neigs
            rem_edge!(g, Edge(n, i))
        end
        if v != n
            for i in neigs
                add_edge!(g, Edge(v, i))
            end
        end
    end

    g.vertices = 1:n-1
    pop!(g.fadjlist)
    if is_directed(g)
        pop!(g.badjlist)
    end
    return true
end

"""Return the number of edges which start at vertex `v`."""
indegree(g::SimpleGraph, v::Int) = length(badj(g,v))
"""Return the number of edges which end at vertex `v`."""
outdegree(g::SimpleGraph, v::Int) = length(fadj(g,v))


indegree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
degree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]

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

"""
    degree_histogram(g)

Returns a `StatsBase.Histogram` of the degrees of vertices in `g`.
"""
degree_histogram(g::SimpleGraph) = fit(Histogram, degree(g))

"""Returns a list of all neighbors connected to vertex `v` by an incoming edge.

NOTE: returns a reference, not a copy. Do not modify result.
"""
in_neighbors(g::SimpleGraph, v::Int) = badj(g,v)
"""Returns a list of all neighbors connected to vertex `v` by an outgoing edge.

NOTE: returns a reference, not a copy. Do not modify result.
"""
out_neighbors(g::SimpleGraph, v::Int) = fadj(g,v)

"""Returns a list of all neighbors of vertex `v` in `g`.

For DiGraphs, this is equivalent to `out_neighbors(g, v)`.

NOTE: returns a reference, not a copy. Do not modify result.
"""
neighbors(g::SimpleGraph, v::Int) = out_neighbors(g, v)

"Returns the neighbors common to vertices `u` and `v` in `g`."
common_neighbors(g::SimpleGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))

"Returns true if `g` has any self loops."
has_self_loop(g::SimpleGraph) = any(v->has_edge(g, v, v), vertices(g))
