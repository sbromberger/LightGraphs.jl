module SimpleWeightedGraphs


import Base:
    eltype, show, ==, Pair, Tuple, copy, length, start, next, done, issubset, zero

import LightGraphs:
    _NI, _insert_and_dedup!, AbstractGraph, AbstractEdge, AbstractEdgeIter,
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    add_vertex!, add_edge!, rem_vertex!, rem_edge!,
    has_vertex, has_edge, in_neighbors, out_neighbors,

    indegree, outdegree, degree, has_self_loops, num_self_loops,

    add_vertices!, adjacency_matrix, dijkstra_shortest_paths

export AbstractSimpleWeightedGraph, AbstractSimpleWeightedDiGraph, AbstractSimpleWeightedEdge,
    SimpleWeightedEdge, SimpleWeightedGraph, SimpleWeightedGraphEdge,
    SimpleWeightedDiGraph, SimpleWeightedDiGraphEdge, weights

include("simpleweightededge.jl")

"""
    AbstractSimpleWeightedGraph

An abstract type representing a simple graph structure.
AbstractSimpleWeightedGraphs must have the following elements:
- weightmx::AbstractSparseMatrix{Real}
"""
abstract type AbstractSimpleWeightedGraph <: AbstractGraph end

function show(io::IO, g::AbstractSimpleWeightedGraph)
    if is_directed(g)
        dir = "directed"
    else
        dir = "undirected"
    end
    if nv(g) == 0
        print(io, "empty $dir simple $(eltype(g)) weighted graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} $dir simple $(eltype(g)) graph with $(weighttype(g)) weights")
    end
end

nv(g::AbstractSimpleWeightedGraph) = eltype(g)(size(g.weights, 1))
vertices(g::AbstractSimpleWeightedGraph) = one(eltype(g)):nv(g)
weights(g::AbstractSimpleWeightedGraph) = g.weights

function fadj(g::AbstractSimpleWeightedGraph)
    mat = g.weights
    return [mat.rowval[mat.colptr[i]:mat.colptr[i+1]-1] for i in 1:nv(g)]
end

function fadj(g::AbstractSimpleWeightedGraph, v::Integer)
    mat = g.weights
    return mat.rowval[mat.colptr[v]:mat.colptr[v+1]-1]
end

badj(x...) = _NI("badj")

has_edge(g::AbstractSimpleWeightedGraph, e::AbstractSimpleWeightedEdge) =
    g.weights[dst(e), src(e)] != zero(weighttype(g))

# handles single-argument edge constructors such as pairs and tuples
has_edge(g::AbstractSimpleWeightedGraph, x) = has_edge(g, edgetype(g)(x))
add_edge!(g::AbstractSimpleWeightedGraph, x) = add_edge!(g, edgetype(g)(x))

# handles two-argument edge constructors like src,dst
has_edge(g::AbstractSimpleWeightedGraph, x, y) = has_edge(g, edgetype(g)(x, y, 0))
add_edge!(g::AbstractSimpleWeightedGraph, x, y) = add_edge!(g, edgetype(g)(x, y, 1))
add_edge!(g::AbstractSimpleWeightedGraph, x, y, z) = add_edge!(g, edgetype(g)(x, y, z))

in_neighbors(g::AbstractSimpleWeightedGraph, v::Integer) = badj(g,v)
out_neighbors(g::AbstractSimpleWeightedGraph, v::Integer) = fadj(g,v)

function issubset(g::T, h::T) where T<:AbstractSimpleWeightedGraph
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) && issubset(edges(g), edges(h))
end

has_vertex(g::AbstractSimpleWeightedGraph, v::Integer) = v in vertices(g)

ne(g::AbstractSimpleWeightedGraph) = nnz(g.weights)

function rem_edge!(g::AbstractSimpleWeightedGraph, u::Integer, v::Integer)
    T = eltype(g)
    rem_edge!(g, edgetype(g)(T(u), T(v)))
end

@doc_str """
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`. Return false if removal fails
(e.g., if vertex is not in the graph); true otherwise.

### Performance
Time complexity is ``\\mathcal{O}(k^2)``, where ``k`` is the max of the degrees
of vertex ``v`` and vertex ``|V|``.

### Implementation Notes
This operation has to be performed carefully if one keeps external
data structures indexed by edges or vertices in the graph, since
internally the removal results in all vertices with indices greater than `v`
being shifted down one.
"""
function rem_vertex!(g::AbstractSimpleWeightedGraph, v::Integer)
    v in vertices(g) || return false
    n = nv(g)

    newweights = g.weights[1:nv(g) .!= v, : ]
    newweights = newweights[:, 1:nv(g) .!= v]

    g.weights = newweights
    return true
end

zero(g::T) where T<:AbstractSimpleWeightedGraph = T()

# TODO: manipulte SparseMatrixCSC directly
add_vertex!(g::AbstractSimpleWeightedGraph) = add_vertices!(g, 1)


##### OVERRIDES FOR EFFICIENCY / CORRECTNESS

function add_vertices!(g::AbstractSimpleWeightedGraph, n::Integer)
    T = eltype(g)
    U = weighttype(g)
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    emptycols = spzeros(U, nv(g) + n, n)
    g.weights = hcat(g.weights, emptycols[1:nv(g), :])
    g.weights = vcat(g.weights, emptycols')
    return true
end


function adjacency_matrix(g::AbstractSimpleWeightedGraph, dir::Symbol=:out, T::DataType=Int)
    if dir == :out
        return T.(spones(g.weights))'
    else
        return T.(spones(g.weights))
    end
end

dijkstra_shortest_paths(g::AbstractSimpleWeightedGraph, src::Int) = dijkstra_shortest_paths(g, src, weights(g))
# include("simpledigraph.jl")
include("simpleweightedgraph.jl")


end # module
