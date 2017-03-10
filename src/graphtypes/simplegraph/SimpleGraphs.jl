module SimpleGraphs

import Base:show, ==, Pair, Tuple, copy
import LightGraphs: _insert_and_dedup!, AbstractGraph, edges, vertices,
nv, ne, fadj, badj, adj, degree, indegree, outdegree, in_neighbors, out_neighbors,
all_neighbors, neighbors, common_neighbors, issubset, add_vertex!, add_vertices!, rem_vertex!,
has_edge, in_edges, out_edges, has_vertex,
add_edge!, rem_edge!, is_directed, num_self_loops, has_self_loops, density

import LightGraphs.SimpleEdges: AbstractSimpleEdge, SimpleEdge, src, dst, reverse

export AbstractSimpleGraph, AbstractSimpleDiGraph,
SimpleGraph, SimpleGraphEdge,
SimpleDiGraph, SimpleDiGraphEdge


"""
AbstractSimpleGraphs must have the following elements:
- vertices::UnitRange{Integer}
- fadjlist::Vector{Vector{Integer}}
- ne::Integer
"""
abstract AbstractSimpleGraph <: AbstractGraph
typealias AbstractSimpleGraphEdge AbstractSimpleEdge

function show(io::IO, g::AbstractSimpleGraph)
  if is_directed(g)
    dir = "directed"
  else
    dir = "undirected"
  end
  if nv(g) == 0
    print(io, "empty $dir simple graph")
  else
    print(io, "{$(nv(g)), $(ne(g))} $dir simple graph")
    end
end

vertices(g::AbstractSimpleGraph) = g.vertices
nv(g::AbstractSimpleGraph) = length(vertices(g))

fadj(g::AbstractSimpleGraph) = g.fadjlist
fadj(g::AbstractSimpleGraph, v::Int) = g.fadjlist[v]


badj(g::AbstractSimpleGraph) = _NI
badj(g::AbstractSimpleGraph, v::Int) = _NI

indegree(g::AbstractSimpleGraph, v::Int) = length(badj(g,v))
outdegree(g::AbstractSimpleGraph, v::Int) = length(fadj(g,v))
degree(g::AbstractSimpleGraph, v::Int) = _NI()

in_neighbors(g::AbstractSimpleGraph, v::Int) = badj(g,v)
out_neighbors(g::AbstractSimpleGraph, v::Int) = fadj(g,v)

neighbors(g::AbstractSimpleGraph, v::Int) = out_neighbors(g, v)
common_neighbors(g::AbstractSimpleGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))

function issubset{T<:AbstractSimpleGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) && issubset(edges(g), edges(h))
end


function add_vertices!{T<:AbstractSimpleGraph}(g::T, n::Integer)
    added = true
    for i = 1:n
        added &= add_vertex!(g)
    end
    return added
end

has_edge{T<:AbstractSimpleGraph}(g::T, u::Int, v::Int) = has_edge(g, edgetype(g)(u, v))
in_edges{T<:AbstractSimpleGraph}(g::T, v::Int) = [edgetype(g)(x,v) for x in badj(g, v)]
out_edges{T<:AbstractSimpleGraph}(g::T, v::Int) = [edgetype(g)(v,x) for x in fadj(g,v)]
has_vertex{T<:AbstractSimpleGraph}(g::T, v::Int) = v in vertices(g)

ne{T<:AbstractSimpleGraph}(g::T) = g.ne
add_edge!{T<:AbstractSimpleGraph}(g::T, u::Int, v::Int) = add_edge!(g, edgetype(g)(u, v))
rem_edge!{T<:AbstractSimpleGraph}(g::T, u::Int, v::Int) = rem_edge!(g, edgetype(g)(u, v))

function rem_vertex!{T<:AbstractSimpleGraph}(g::T, v::Int)
    v in vertices(g) || return false
    n = nv(g)

    edgs = in_edges(g, v)
    for e in edgs
        rem_edge!(g, e)
    end
    neigs = copy(in_neighbors(g, n))
    for i in neigs
        rem_edge!(g, edgetype(g)(i, n))
    end
    if v != n
        for i in neigs
            add_edge!(g, edgetype(g)(i, v))
        end
    end

    if is_directed(g)
        edgs = out_edges(g, v)
        for e in edgs
            rem_edge!(g, e)
        end
        neigs = copy(out_neighbors(g, n))
        for i in neigs
            rem_edge!(g, edgetype(g)(n, i))
        end
        if v != n
            for i in neigs
                add_edge!(g, edgetype(g)(v, i))
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

include("simpledigraph.jl")
include("simplegraph.jl")




end # module
