module SimpleGraphs

using SparseArrays
using LinearAlgebra
using LightGraphs
using SimpleTraits

import Base:
    eltype, show, ==, Pair, Tuple, copy, length, issubset, reverse, zero, in, iterate

import LightGraphs:
    _NI, AbstractGraph, AbstractEdge, AbstractEdgeIter,
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    has_contiguous_vertices, has_vertex, has_edge, inneighbors, outneighbors, all_neighbors,
  	deepcopy_adjlist, indegree, outdegree, degree, has_self_loops,
	num_self_loops, insorted

using Random: GLOBAL_RNG, AbstractRNG

export AbstractSimpleGraph, AbstractSimpleEdge,
    SimpleEdge, SimpleGraph, SimpleGraphFromIterator, SimpleGraphEdge,
    SimpleDiGraph, SimpleDiGraphFromIterator, SimpleDiGraphEdge,
    add_vertex!, add_edge!, rem_vertex!, rem_vertices!, rem_edge!,
    # randgraphs
    erdos_renyi, expected_degree_graph, watts_strogatz, random_regular_graph,
    random_regular_digraph, random_configuration_model, random_tournament_digraph,
    StochasticBlockModel, make_edgestream, nearbipartiteSBM, blockcounts,
    blockfractions, stochastic_block_model, barabasi_albert, dorogovtsev_mendes,
    barabasi_albert!, static_fitness_model, static_scale_free, kronecker, random_orientation_dag,
    #generators
    complete_graph, star_graph, path_graph, wheel_graph, cycle_graph,
    complete_bipartite_graph, complete_multipartite_graph, turan_graph, complete_digraph,
    star_digraph, path_digraph, grid, wheel_digraph, cycle_digraph, binary_tree,
    double_binary_tree, roach_graph, clique_graph, barbell_graph, lollipop_graph,
    ladder_graph, circular_ladder_graph,
    #smallgraphs
    smallgraph,
    # Euclidean graphs
    euclidean_graph


"""
    AbstractSimpleGraph

An abstract type representing a simple graph structure.
`AbstractSimpleGraph`s must have the following elements:
  - `vertices::UnitRange{Integer}`
  - `fadjlist::Vector{Vector{Integer}}`
  - `ne::Integer`
"""
abstract type AbstractSimpleGraph{T<:Integer} <: AbstractGraph{T} end

function show(io::IO, g::AbstractSimpleGraph{T}) where T
    dir = is_directed(g) ? "directed" : "undirected"
    print(io, "{$(nv(g)), $(ne(g))} $dir simple $T graph")
end

nv(g::AbstractSimpleGraph{T}) where T = T(length(fadj(g)))

"""
    throw_if_invalid_eltype(T)

Internal function, throw a `DomainError` if `T` is not a concrete type `Integer`.
Can be used in the constructor of AbstractSimpleGraphs,
as Julia's typesystem does not enforce concrete types, which can lead to
problems. E.g `SimpleGraph{Signed}`.
"""
function throw_if_invalid_eltype(T::Type{<:Integer})
    if !isconcretetype(T)
        throw(DomainError(T, "Eltype for AbstractSimpleGraph must be concrete type."))
    end
end


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

function issubset(g::T, h::T) where T <: AbstractSimpleGraph
    nv(g) <= nv(h) || return false
    for u in vertices(g)
        u_nbrs_g = neighbors(g, u)
        len_u_nbrs_g = length(u_nbrs_g)
        len_u_nbrs_g == 0 && continue
        u_nbrs_h = neighbors(h, u)
        p = 1
        len_u_nbrs_g > length(u_nbrs_h) && return false
		(u_nbrs_g[1] < u_nbrs_h[1] || u_nbrs_g[end] > u_nbrs_h[end]) && return false
        @inbounds for v in u_nbrs_h
            if v == u_nbrs_g[p]
                p == len_u_nbrs_g && break
                p += 1
            end
        end
        p == len_u_nbrs_g || return false
    end
    return true
end

has_vertex(g::AbstractSimpleGraph, v::Integer) = v in vertices(g)

ne(g::AbstractSimpleGraph) = g.ne

function rem_edge!(g::AbstractSimpleGraph{T}, u::Integer, v::Integer) where T
    rem_edge!(g, edgetype(g)(T(u), T(v)))
end

"""
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`. Return `false` if removal fails
(e.g., if vertex is not in the graph); `true` otherwise.

### Performance
Time complexity is ``\\mathcal{O}(k^2)``, where ``k`` is the max of the degrees
of vertex ``v`` and vertex ``|V|``.

### Implementation Notes
This operation has to be performed carefully if one keeps external
data structures indexed by edges or vertices in the graph, since
internally the removal is performed swapping the vertices `v`  and ``|V|``,
and removing the last vertex ``|V|`` from the graph. After removal the
vertices in `g` will be indexed by ``1:|V|-1``.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(2);

julia> rem_vertex!(g, 2)
true

julia> rem_vertex!(g, 2)
false
```
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

zero(::Type{G}) where {G<:AbstractSimpleGraph} = G()

has_contiguous_vertices(::Type{G}) where {G<:AbstractSimpleGraph} = true

include("./simpleedge.jl")
include("./simpledigraph.jl")
include("./simplegraph.jl")
include("./simpleedgeiter.jl")
include("./generators/deprecations.jl")
include("./generators/staticgraphs.jl")
include("./generators/randgraphs.jl")
include("./generators/euclideangraphs.jl")
include("./generators/smallgraphs.jl")

end # module
