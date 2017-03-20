module SimpleGraphs

import Base:
    eltype, show, ==, Pair, Tuple, copy, length, start, next, done, issubset

import LightGraphs:
    _NI, _insert_and_dedup!, AbstractGraph, AbstractEdge, AbstractEdgeIter,
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    add_vertex!, add_edge!, rem_vertex!, rem_edge!,
    has_vertex, has_edge, in_neighbors, out_neighbors,

    indegree, outdegree, degree, has_self_loops, num_self_loops, empty

export AbstractSimpleGraph, AbstractSimpleDiGraph, AbstractSimpleEdge,
    SimpleEdge, SimpleGraph, SimpleGraphEdge,
    SimpleDiGraph, SimpleDiGraphEdge


"""
AbstractSimpleGraphs must have the following elements:
- vertices::UnitRange{Integer}
- fadjlist::Vector{Vector{Integer}}
- ne::Integer
"""
abstract type AbstractSimpleGraph <: AbstractGraph end

function show(io::IO, g::AbstractSimpleGraph)
    if is_directed(g)
        dir = "directed"
    else
        dir = "undirected"
    end
    if nv(g) == 0
        print(io, "empty $dir simple $(eltype(g)) graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} $dir simple $(eltype(g)) graph")
    end
end

vertices(g::AbstractSimpleGraph) = g.vertices
edges(g::AbstractSimpleGraph) = SimpleEdgeIter(g)
nv(g::AbstractSimpleGraph) = last(vertices(g))

fadj(g::AbstractSimpleGraph) = g.fadjlist
fadj(g::AbstractSimpleGraph, v::Integer) = g.fadjlist[v]


badj(x...) = _NI("badj")

has_edge(g::AbstractSimpleGraph, u::Integer, v::Integer) = has_edge(g, edgetype(g)(u,v))

function add_edge!(g::AbstractSimpleGraph, u::Integer, v::Integer)
    T = eltype(g)
    add_edge!(g, edgetype(g)(T(u),T(v)))
end

in_neighbors(g::AbstractSimpleGraph, v::Integer) = badj(g,v)
out_neighbors(g::AbstractSimpleGraph, v::Integer) = fadj(g,v)

function issubset(g::T, h::T) where T<:AbstractSimpleGraph
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) && issubset(edges(g), edges(h))
end

has_vertex(g::AbstractSimpleGraph, v::Integer) = v in vertices(g)

ne(g::AbstractSimpleGraph) = g.ne
function rem_edge!(g::AbstractSimpleGraph, u::Integer, v::Integer)
    T = eltype(g)
    rem_edge!(g, edgetype(g)(T(u), T(v)))
end

"""
Remove the vertex `v` from graph `g`.
This operation has to be performed carefully if one keeps external
data structures indexed by edges or vertices in the graph, since
internally the removal is performed swapping the vertices `v`  and `n=nv(g)`,
and removing the vertex `n` from the graph. After removal the vertices in the ` g` will be indexed by 1:n-1.
This is an O(k^2) operation, where `k` is the max of the degrees of vertices `v` and `n`.
Returns false if removal fails (e.g., if vertex is not in the graph); true otherwise.
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

    g.vertices = 1:n-1
    pop!(g.fadjlist)
    if is_directed(g)
        pop!(g.badjlist)
    end
    return true
end
empty{T<:AbstractSimpleGraph}(g::T) = T()

include("simpleedge.jl")
include("simpledigraph.jl")
include("simplegraph.jl")
include("simpleedgeiter.jl")

end # module
