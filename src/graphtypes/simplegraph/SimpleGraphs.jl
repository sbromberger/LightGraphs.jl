module SimpleGraphs

import Base:
  eltype, show, ==, Pair, Tuple, copy, length, start, next, done, issubset

import LightGraphs:
  _insert_and_dedup!, AbstractGraph, AbstractEdge, AbstractEdgeIter,
  src, dst, edgetype, nv, ne, vertices, edges, is_directed,
  add_vertex!, add_edge!, rem_vertex!, rem_edge!,
  has_vertex, has_edge, in_neighbors, out_neighbors,

  indegree, outdegree, degree, has_self_loops, num_self_loops

export AbstractSimpleGraph, AbstractSimpleDiGraph, AbstractSimpleEdge,
SimpleEdge, SimpleGraph, SimpleGraphEdge,
SimpleDiGraph, SimpleDiGraphEdge,
fadj, badj, adj


"""
AbstractSimpleGraphs must have the following elements:
- vertices::UnitRange{Integer}
- fadjlist::Vector{Vector{Integer}}
- ne::Integer
"""
abstract AbstractSimpleGraph <: AbstractGraph



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
edges(g::AbstractSimpleGraph) = SimpleEdgeIter(g)
nv(g::AbstractSimpleGraph) = length(vertices(g))

fadj(g::AbstractSimpleGraph) = g.fadjlist
fadj(g::AbstractSimpleGraph, v::Int) = g.fadjlist[v]


badj(g::AbstractSimpleGraph) = _NI
badj(g::AbstractSimpleGraph, v::Int) = _NI

has_edge(g::AbstractSimpleGraph, u::Int, v::Int) = has_edge(g, SimpleEdge(u,v))
add_edge!(g::AbstractSimpleGraph, u::Int, v::Int) = add_edge!(g, SimpleEdge(u,v))

in_neighbors(g::AbstractSimpleGraph, v::Int) = badj(g,v)
out_neighbors(g::AbstractSimpleGraph, v::Int) = fadj(g,v)

neighbors(g::AbstractSimpleGraph, v::Int) = out_neighbors(g, v)


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
in_edges{T<:AbstractSimpleGraph}(g::T, v::Int) = [edgetype(g)(x,v) for x in in_neighbors(g, v)]
out_edges{T<:AbstractSimpleGraph}(g::T, v::Int) = [edgetype(g)(v,x) for x in out_neighbors(g, v)]
has_vertex{T<:AbstractSimpleGraph}(g::T, v::Int) = v in vertices(g)

ne{T<:AbstractSimpleGraph}(g::T) = g.ne
add_edge!{T<:AbstractSimpleGraph}(g::T, u::Int, v::Int) = add_edge!(g, edgetype(g)(u, v))
rem_edge!{T<:AbstractSimpleGraph}(g::T, u::Int, v::Int) = rem_edge!(g, edgetype(g)(u, v))

"""
Remove the vertex `v` from graph `g`.
This operation has to be performed carefully if one keeps external
data structures indexed by edges or vertices in the graph, since
internally the removal is performed swapping the vertices `v`  and `n=nv(g)`,
and removing the vertex `n` from the graph. After removal the vertices in the ` g` will be indexed by 1:n-1.
This is an O(k^2) operation, where `k` is the max of the degrees of vertices `v` and `n`.
Returns false if removal fails (e.g., if vertex is not in the graph); true otherwise.
"""
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

include("simpleedge.jl")
include("simpledigraph.jl")
include("simplegraph.jl")
include("simpleedgeiter.jl")





end # module
