module SimpleGraphsCore

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
  	indegree, outdegree, degree, has_self_loops,
	num_self_loops, insorted

import LightGraphs: reverse, merge_vertices, merge_vertices!, add_edge!, add_vertex!, rem_edge!, rem_vertex!, add_vertices!, rem_vertices!, squash

# export AbstractSimpleGraph, AbstractSimpleEdge, SimpleGraph, SimpleDiGraph, SimpleEdge,
# add_vertex!, add_edge!, rem_vertex!, rem_vertices!, rem_edge!, add_vertices!, squash

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
    add_vertices!(g, n)

Add `n` new vertices to the graph `g`.
Return the number of vertices that were added successfully.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph()
{0, 0} undirected simple Int64 graph

julia> add_vertices!(g, 2)
2
```
"""
add_vertices!(g::AbstractSimpleGraph, n::Integer) = sum([add_vertex!(g) for i = 1:n])

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


"""
    squash(g)

Return a copy of a graph with the smallest practical type that
can accommodate all vertices.
"""
function squash end

# """
#     Graph
#
# A datastruture representing an undirected graph.
# """
# const Graph = LightGraphs.SimpleGraphs.SimpleGraph
# """
#     DiGraph
#
# A datastruture representing a directed graph.
# """
# const DiGraph = LightGraphs.SimpleGraphs.SimpleDiGraph
# """
#     Edge
#
# A datastruture representing an edge between two vertices in
# a `Graph` or `DiGraph`.
# """
# const Edge = LightGraphs.SimpleGraphs.SimpleEdge

"""
NOTE: THIS MODULE IS NOT TO BE USED OUTSIDE OF THE LIGHTGRAPHS
LIBRARY CODE.

A module containing the core SimpleGraphs structures and methods.
Separation of this code into its own module is necessary to avoid
circular dependencies, as some LightGraphs library code requires the
ability to create temporary graph structures, and the SimpleGraphs
Generators in turn rely on the libary code.

The SimpleGraphs module will extend this once the library code has
been imported. Do not use anything in this module directly.
"""
SimpleGraphsCore
include("./utils.jl")
include("./simpleedge.jl")
include("./simpledigraph.jl")
include("./simplegraph.jl")
include("./simpleedgeiter.jl")
end # module
