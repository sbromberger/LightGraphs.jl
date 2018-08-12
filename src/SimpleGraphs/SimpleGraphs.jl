module SimpleGraphs

using SparseArrays
using LinearAlgebra
using LightGraphs

import Base:
    eltype, show, ==, <, isless, Pair, Tuple, copy, length, issubset, zero, in, iterate

import LightGraphs:
    _NI, AbstractGraph, AbstractEdge, AbstractEdgeIter,
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    has_vertex, has_edge, inneighbors, outneighbors,

    indegree, outdegree, degree, has_self_loops, num_self_loops, insorted

export AbstractSimpleGraph, AbstractSimpleEdge,
    SimpleEdge, SimpleGraph, SimpleGraphFromIterator, SimpleGraphEdge,
    SimpleDiGraph, SimpleDiGraphFromIterator, SimpleDiGraphEdge,
    add_vertex!, add_edge!, rem_vertex!, rem_edge!,
    # randgraphs
    erdos_renyi, expected_degree_graph, watts_strogatz, random_regular_graph,
    random_regular_digraph, random_configuration_model, random_tournament_digraph, 
    StochasticBlockModel, make_edgestream, nearbipartiteSBM, blockcounts, 
    blockfractions, stochastic_block_model, barabasi_albert,
    barabasi_albert!, static_fitness_model, static_scale_free, kronecker,
    #generators
    CompleteGraph, StarGraph, PathGraph, WheelGraph, CycleGraph,
    CompleteBipartiteGraph, CompleteDiGraph, StarDiGraph, PathDiGraph, Grid,
    WheelDiGraph, CycleDiGraph, BinaryTree, DoubleBinaryTree, RoachGraph, CliqueGraph,
    #smallgraphs
    smallgraph,
    # Euclidean graphs
    euclidean_graph


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
    dir = is_directed(g) ? "directed" : "undirected"
    print(io, "{$(nv(g)), $(ne(g))} $dir simple $T graph")
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

inneighbors(g::AbstractSimpleGraph, v::Integer) = badj(g, v)
outneighbors(g::AbstractSimpleGraph, v::Integer) = fadj(g, v)

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

"""
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
    self_loop_n = false  # true if n is self-looped (see #820)

    # remove the in_edges from v
    srcs = copy(inneighbors(g, v))
    @inbounds for s in srcs
        rem_edge!(g, edgetype(g)(s, v))
    end
    # remove the in_edges from the last vertex
    neigs = copy(inneighbors(g, n))
    @inbounds for s in neigs
        rem_edge!(g, edgetype(g)(s, n))
    end
    if v != n
        # add the edges from n back to v
        @inbounds for s in neigs
            if s != n  # don't add an edge to the last vertex - see #820.
                add_edge!(g, edgetype(g)(s, v))
            else
                self_loop_n = true
            end
        end
    end

    if is_directed(g)
        # remove the out_edges from v
        dsts = copy(outneighbors(g, v))
        @inbounds for d in dsts
            rem_edge!(g, edgetype(g)(v, d))
        end
        # remove the out_edges from the last vertex
        neigs = copy(outneighbors(g, n))
        @inbounds for d in neigs
            rem_edge!(g, edgetype(g)(n, d))
        end
        if v != n
            # add the out_edges back to v
            @inbounds for d in neigs
                if d != n
                    add_edge!(g, edgetype(g)(v, d))
                end
            end
        end
    end
    if self_loop_n
        add_edge!(g, edgetype(g)(v, v))
    end
    pop!(g.fadjlist)
    if is_directed(g)
        pop!(g.badjlist)
    end
    return true
end

zero(g::T) where T<:AbstractSimpleGraph = T()

include("./simpleedge.jl")
include("./simpledigraph.jl")
include("./simplegraph.jl")
include("./simpleedgeiter.jl")
include("./generators/staticgraphs.jl")
include("./generators/randgraphs.jl")
include("./generators/euclideangraphs.jl")
include("./generators/smallgraphs.jl")

end # module
