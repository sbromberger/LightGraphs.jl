abstract AbstractPathState

abstract SimpleGraph
abstract AbstractSparseGraph<:SimpleGraph

if VERSION < v"0.4.0-dev+818"
    immutable Pair{T1,T2}
        first::T1
        second::T2
    end

end

if VERSION < v"0.4.0-dev+4103"
    reverse(p::Pair) = Pair(p.second, p.first)
end

_column(a::AbstractSparseArray, i::Integer) = sub(a.rowval, a.colptr[i]:a.colptr[i+1]-1)

# material nonimplication - test
⊅(p::Bool, q::Bool) = p & !q

function ⊅{Ti, Tv}(a::SparseMatrixCSC{Ti, Tv}, b::SparseMatrixCSC)
    (m,n) = size(a)
    wipcolptr = Vector{Tv}()
    sizehint!(wipcolptr, n+1)
    push!(wipcolptr, one(Tv))
    wipnzval = Vector{Ti}()
    wiprowval = Vector{Tv}()
    runninglenr = 1

    @inbounds @simd for c = 1:n
        wipr = Vector{Tv}()
        for r in _column(a,c)
            # info("row $r, col $c")
            if !b[r,c]
                push!(wipr, r)
            end
        end
        lenr = length(wipr)
        runninglenr += lenr
        push!(wipcolptr, runninglenr)
        append!(wiprowval, wipr)
        append!(wipnzval, fill(true, lenr))
    end

    return SparseMatrixCSC(a.m, a.n, wipcolptr, wiprowval, wipnzval)
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

type SparseGraph<:AbstractSparseGraph
    edges::Set{Edge}
    fm::SparseMatrixCSC{Bool, Int}
end

type SparseDiGraph<:AbstractSparseGraph
    edges::Set{Edge}
    fm::SparseMatrixCSC{Bool, Int}
    bm::SparseMatrixCSC{Bool, Int}
end


SparseGraph(n::Int) = SparseGraph(Set{Edge}(), spzeros(Bool,n,n))
SparseGraph() = SparseGraph(0)

function SparseGraph{T}(a::AbstractArray{T,2})
    isequal(size(a)...) || error("Matrix must be square")
    spmx = sparse(a .!= zero(T))
    issym(spmx) || error("Matrix must be symmetric")
    g = SparseGraph()
    for c in 1:spmx.m
        for r in _column(spmx, c)
            r > c && break
            push!(g.edges, Edge(r,c))
        end
    end

    g.fm = spmx | spmx'
    return g
end
SparseGraph(g::SparseDiGraph) = SparseGraph(g.fm|g.bm)

SparseDiGraph(n::Int) = SparseDiGraph(Set{Edge}(), spzeros(Float64,n,n), spzeros(Bool,n,n))
SparseDiGraph() = SparseDiGraph(0)

function SparseDiGraph{T}(a::AbstractArray{T,2}, major::Symbol=:byrow)
    isequal(size(a)...) || error("Matrix must be square")
    major == :byrow || major == :bycol || error("Invalid major")
    spmx = sparse(a .!= zero(T))
    g = SparseDiGraph()
    for c in 1:spmx.m
        for r in _column(spmx, c)
            if major == :byrow
                push!(g.edges, Edge(r,c))
            else
                push!(g.edges, Edge(c,r))
            end
        end
    end
    if major == :byrow
        g.fm = spmx'
        g.bm = spmx
    elseif major == :bycol
        g.fm = spmx
        g.bm = spmx'
    end
    return g
end
SparseDiGraph(g::SparseGraph) = SparseDiGraph(g.fm)

is_directed(g::SparseDiGraph) = true
is_directed(g::SparseGraph) = false

"""Return the vertices of a graph."""
vertices(g::AbstractSparseGraph) = 1:size(g.fm, 1)

"""Return the edges of a graph."""
edges(g::AbstractSparseGraph) = g.edges


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


fadj(g::AbstractSparseGraph, v::Int) = _column(g.fm, v)
fadj(g::AbstractSparseGraph) = [fadj(g,i) for i in 1:nv(g)]


"""Returns the backwards adjacency list of a graph.
For each vertex the Array of `dst` for each edge eminating from that vertex."""
badj(g::SparseGraph, x...) = fadj(g, x...)  # for undirected, this is the same as fadj.
badj(g::SparseDiGraph, v::Int) = _column(g.bm, v)
badj(g::SparseDiGraph) = [badj(g,i) for i in vertices(g)]


"""Returns the forward adjacency matrix of a graph"""
fmat(g::AbstractSparseGraph) = g.fm
"""Returns the backward adjacency matrix of a graph"""
bmat(g::SparseDiGraph) = g.bm
bmat(g::SparseGraph) = g.fm

"""Returns true if all of the vertices and edges of `g` are contained in `h`."""
function issubset{T<:SimpleGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) && issubset(edges(g), edges(h))
end

"""Add a new vertex to the graph `g`."""
function add_vertex!(g::SparseGraph)
    g.fm.m += 1
    g.fm.n += 1
    push!(g.fm.colptr, g.fm.colptr[end])
    return g.fm.m
end

function add_vertex!(g::SparseDiGraph)
    g.fm.m += 1
    g.fm.n += 1
    push!(g.fm.colptr, g.fm.colptr[end])
    g.bm.m += 1
    g.bm.n += 1
    push!(g.bm.colptr, g.bm.colptr[end])
    return g.fm.m
end


"""Add `n` new vertices to the graph `g`."""
function add_vertices!(g::SparseGraph, n::Integer)
    g.fm.m += n
    g.fm.n += n
    append!(g.fm.colptr, fill(g.fm.colptr[end], n))
    return g.fm.m
end

function add_vertices!(g::SparseDiGraph, n::Integer)
    g.fm.m += n
    g.fm.n += n
    append!(g.fm.colptr, fill(g.fm.colptr[end], n))
    g.bm.m += n
    g.bm.n += n
    append!(g.bm.colptr, fill(g.bm.colptr[end], n))
    return g.fm.m
end

"""Return true if the graph `g` has an edge from `src` to `dst`."""
has_edge(g::SimpleGraph, e::Edge) = has_edge(g, src(e), dst(e))
has_edge(g::SimpleGraph, s::Int, d::Int) = d <= nv(g) && s <= nv(g) && fmat(g)[d, s]

"""Return an Array of the edges in `g` that arrive at vertex `v`."""
in_edges(g::SimpleGraph, v::Int) = [Edge(x,v) for x in badj(g,v)]
"""Return an Array of the edges in `g` that emanate from vertex `v`."""
out_edges(g::SimpleGraph, v::Int) = [Edge(v,x) for x in fadj(g,v)]


"""Return true if `v` is a vertex of `g`."""
has_vertex(g::SimpleGraph, v::Int) = v in vertices(g)

"""The number of vertices in `g`."""
nv(g::AbstractSparseGraph) = fmat(g).m


"""The number of edges in `g`."""
ne(g::SimpleGraph) = length(edges(g))

doc"""Density is defined as the ratio of the number of actual edges to the
number of possible edges. This is $|v| |v-1|$ for directed graphs and
$(|v| |v-1|) / 2$ for undirected graphs.
"""
density(g::SparseGraph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
density(g::SparseDiGraph) = ne(g) / (nv(g) * (nv(g)-1))


"""Add a new edge to `g` from `src` to `dst`."""
add_edge!(g::SimpleGraph, s::Int, d::Int) = add_edge!(g, Edge(s,d))

function add_edge!(g::SparseGraph, e::Edge)
    s, d = src(e), dst(e)
    g.fm[d,s] = true
    g.fm[s,d] = true
    push!(g.edges, e)
    return e
end

function add_edge!(g::SparseDiGraph, e::Edge)
    s, d = src(e), dst(e)
    g.fm[d,s] = true
    g.bm[s,d] = true
    push!(g.edges, e)
    return e
end

"""Add multiple edges (from a set of Edges) to `g`."""
function add_edges!(g::SparseGraph, es::Set{Edge})
    nes = length(es)
    i = [dst(e) for e in es]
    j = [src(e) for e in es]
    issubset(i,vertices(g)) && issubset(j,vertices(g)) || error("At least one edge is invalid")
    v = fill(true, nes)
    newedgemx = sparse(i,j,v,nv(g),nv(g))
    g.fm |= newedgemx
    g.fm |= newedgemx'
    g.edges = es
end

function add_edges!(g::SparseDiGraph, es::Vector{Edge})
    nes = length(es)
    i = [dst(e) for e in es]
    j = [src(e) for e in es]
    issubset(i,vertices(g)) && issubset(j,vertices(g)) || error("At least one edge is invalid")
    v = fill(true, nes)
    newedgemx = sparse(i,j,v,nv(g),nv(g))
    g.fm |= newedgemx
    g.bm |= newedgemx'
    union!(g.edges, es)
end

add_edges!(g::SimpleGraph, es::Set{Edge}) = add_edges!(g, collect(es))

"""Remove the edge from `src` to `dst`."""
rem_edge!(g::SimpleGraph, s::Int, d::Int) = rem_edge!(g, Edge(s,d))
function rem_edge!(g::SparseGraph, s::Int, d::Int)
    e = Edge(s,d)
    if !(e in edges(g))
        reve = reverse(e)
        (reve in edges(g)) || error("Edge $e is not in graph")
        e = reve
    end
    g.fm[d,s] = false
    g.fm[s,d] = false
    return pop!(g.edges,e)
end

function rem_edge!(g::SparseDiGraph, e::Edge)
    e in edges(g) || error("Edge $e is not in graph")
    s,d = src(e), dst(e)
    g.fm[d,s] = false
    g.bm[s,d] = false
    return pop!(g.edges, e)
end

# TODO: requires material nonimplication to work efficiently.
# function rem_edges!(g::SparseGraph, es::Vector{Edge})
#     eset = Set{Edge}
#     for e in es
#         if !(e in edges(g))
#             reve = reverse(e)
#             (reve in edges(g)) || error("Edge $e is not in graph")
#             e = reve
#         end
#         push!(eset,e)
#     end
#     i = [src(e) for e in es]
#     j = [dst(e) for e in es]
#     v = fill(true, nes)
#     remedgemx = sparse(i,j,v,nv(g),nv(g))
#     g.fm
#     setdiff!(edges(g), es)
#

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

"Returns all the vertices which share an edge with `v`."
all_neighbors(g::SparseDiGraph, v::Int) = union(in_neighbors(g,v), out_neighbors(g,v))


copy(g::SparseGraph) =
    SparseGraph(copy(g.edges), copy(g.fm))

copy(g::SparseDiGraph) =
    SparseDiGraph(copy(g.edges), copy(g.fm), copy(g.bm))

function setindex!(g::SparseGraph, i, s::Int, d::Int)
     if i == zero(typeof(i))
       rem_edge!(g,s,d)
     else
       add_edge!(g,s,d)
   end
end

getindex(g::SparseGraph, s::Int, d::Int) = has_edge(g,s,d)

=={T<:SimpleGraph}(g::T, h::T) = edges(g) == edges(h) && vertices(g) == vertices(h)
function ==(g::SparseGraph, h::SparseGraph)
    revedges = [reverse(x) for x in g.edges]
    return  vertices(g) == vertices(h) &&
            ne(g) == ne(h) &&
            issubset(edges(h), union(g.edges, revedges))
end

# courtesy of Iain Dunning
"Returns true if `g` is has any self loops."
function has_self_loop(g::AbstractSparseGraph)
    n = g.fm.n
    colptr = g.fm.colptr
    rowval = g.fm.rowval
    nzval = g.fm.nzval
    @inbounds for col in 1:n
        for idx in colptr[col]:colptr[col+1]-1
            row = rowval[idx]
            nzv = nzval[idx]
            if (row == col) && nzv
                return true
            elseif row > col
                break
            end
        end
    end
    return false
end


function show(io::IO, g::SparseGraph)
    if nv(g) == 0
        print(io, "empty undirected graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} undirected graph")
    end
end

function show(io::IO, g::SparseDiGraph)
    if nv(g) == 0
        print(io, "empty directed graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} directed graph")
    end
end



typealias Graph SparseGraph
typealias DiGraph SparseDiGraph
