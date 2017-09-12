module SimpleGraphs

import Base:
    eltype, show, ==, Pair, Tuple, copy, length, start, next, done, issubset, zero

import LightGraphs:
    _NI, _insert_and_dedup!, AbstractGraph, AbstractEdge, AbstractEdgeIter,
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    add_vertex!, add_edge!, rem_vertex!, rem_edge!,
    has_vertex, has_edge, in_neighbors, out_neighbors,

    indegree, outdegree, degree, has_self_loops, num_self_loops, insorted

export AbstractSimpleGraph, AbstractSimpleDiGraph, AbstractSimpleEdge,
    SimpleEdge, SimpleGraph, SimpleGraphEdge,
    SimpleDiGraph, SimpleDiGraphEdge


"""
    AbstractSimpleGraph

An abstract type representing a simple graph structure.
AbstractSimpleGraphs must have the following elements:
- vertices::UnitRange{Integer}
- fadjlist::Vector{Vector{Integer}}
- ne::Integer
"""
abstract type AbstractSimpleGraph{T<:Integer} <: AbstractGraph{T} end

function show(io::IO, g::AbstractSimpleGraph{T}) where T
    if is_directed(g)
        dir = "directed"
    else
        dir = "undirected"
    end
    if nv(g) == 0
        print(io, "empty $dir simple $T graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} $dir simple $T graph")
    end
end

nv(g::AbstractSimpleGraph{T}) where T = T(length(fadj(g)))
vertices(g::AbstractSimpleGraph{T}) where T = one(T):nv(g)


edges(g::AbstractSimpleGraph) = SimpleEdgeIter(g)


fadj(g::AbstractSimpleGraph) = g.fadjlist
fadj(g::AbstractSimpleGraph, v::Integer) = g.fadjlist[v]


badj(x...) = _NI("badj")

# handles single-argument edge constructors such as pairs and tuples
has_edge(g::AbstractSimpleGraph, x) = has_edge(g, edgetype(g)(x))
add_edge!(g::AbstractSimpleGraph, x) = add_edge!(g, edgetype(g)(x))

# handles two-argument edge constructors like src,dst
has_edge(g::AbstractSimpleGraph, x, y) = has_edge(g, edgetype(g)(x, y))
add_edge!(g::AbstractSimpleGraph, x, y) = add_edge!(g, edgetype(g)(x, y))

in_neighbors(g::AbstractSimpleGraph, v::Integer) = badj(g, v)
out_neighbors(g::AbstractSimpleGraph, v::Integer) = fadj(g, v)

function issubset(g::T, h::T) where T<:AbstractSimpleGraph
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) && issubset(edges(g), edges(h))
end

has_vertex(g::AbstractSimpleGraph, v::Integer) = v in vertices(g)

ne(g::AbstractSimpleGraph) = g.ne

function rem_edge!(g::AbstractSimpleGraph{T}, u::Integer, v::Integer) where T
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
internally the removal is performed swapping the vertices `v`  and ``|V|``,
and removing the last vertex ``|V|`` from the graph. After removal the
vertices in `g` will be indexed by ``1:|V|-1``.
"""
function rem_vertex!(g::AbstractSimpleGraph, v::Integer)
    v in vertices(g) || return false
    n = nv(g)

    # remove the in_edges from v
    srcs = copy(in_neighbors(g, v))
    for s in srcs
        rem_edge!(g, edgetype(g)(s, v))
    end
    # remove the in_edges from the last vertex
    neigs = copy(in_neighbors(g, n))
    for s in neigs
        rem_edge!(g, edgetype(g)(s, n))
    end
    if v != n
        # add the edges from n back to v
        for s in neigs
            add_edge!(g, edgetype(g)(s, v))
        end
    end

    if is_directed(g)
        # remove the out_edges from v
        dsts = copy(out_neighbors(g, v))
        for d in dsts
            rem_edge!(g, edgetype(g)(v, d))
        end
        # remove the out_edges from the last vertex
        neigs = copy(out_neighbors(g, n))
        for d in neigs
            rem_edge!(g, edgetype(g)(n, d))
        end
        if v != n
            # add the out_edges back to v
            for d in neigs
                add_edge!(g, edgetype(g)(v, d))
            end
        end
    end

    pop!(g.fadjlist)
    if is_directed(g)
        pop!(g.badjlist)
    end
    return true
end

zero(g::T) where T<:AbstractSimpleGraph = T()

include("simpleedge.jl")
include("simpledigraph.jl")
include("simplegraph.jl")
include("simpleedgeiter.jl")

end # module
