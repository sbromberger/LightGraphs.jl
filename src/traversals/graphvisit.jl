# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The concept and trivial implementation of graph visitors

abstract AbstractGraphVisitor

# trivial implementation

# invoked when a vertex v is encountered for the first time
# this function returns whether to continue search
discover_vertex!(vis::AbstractGraphVisitor, v) = true

# invoked when the algorithm is about to examine v's neighbors
open_vertex!(vis::AbstractGraphVisitor, v) = true

# invoked when a neighbor is discovered & examined
examine_neighbor!(vis::AbstractGraphVisitor, u, v, ucolor::Int, vcolor::Int, ecolor::Int) = true

# invoked when all of v's neighbors have been examined
close_vertex!(vis::AbstractGraphVisitor, v) = true


type TrivialGraphVisitor <: AbstractGraphVisitor
end


# This is the common base for BreadthFirst and DepthFirst
abstract AbstractGraphVisitAlgorithm

typealias AbstractEdgeMap{T} Associative{Edge,T}
typealias AbstractVertexMap{T<:Integer, U} Union{AbstractVector{T},Associative{T, U}}

type DummyEdgeMap <: AbstractEdgeMap{Int}
end

getindex(d::DummyEdgeMap, e::Edge) = 0
setindex!(d::DummyEdgeMap, x::Int, e::Edge) = x
get(d::DummyEdgeMap, e::Edge, x::Int) = x


###########################################################
#
#   General algorithms based on graph traversal
#
###########################################################

# List vertices by the order of being discovered

type VertexListVisitor{T<:Integer} <: AbstractGraphVisitor
    vertices::Vector{T}
end

function VertexListVisitor{T<:Integer}(n::T=0)
    vs = Vector{T}()
    sizehint!(vs, n)
    return VertexListVisitor(vs)
end

function discover_vertex!(visitor::VertexListVisitor, v::Integer)
    push!(visitor.vertices, v)
    return true
end

function visited_vertices(
    g::AbstractGraph,
    alg::AbstractGraphVisitAlgorithm,
    sources)
    T = eltype(g)
    visitor = VertexListVisitor(nv(g))
    traverse_graph!(g, alg, sources, visitor)
    visitor.vertices::Vector{T}
end


# Print visit log

type LogGraphVisitor{S<:IO} <: AbstractGraphVisitor
    io::S
end

function discover_vertex!(vis::LogGraphVisitor, v::Integer)
    println(vis.io, "discover vertex: $v")
    return true
end

function open_vertex!(vis::LogGraphVisitor, v::Integer)
    println(vis.io, "open vertex: $v")
    return true
end

function close_vertex!(vis::LogGraphVisitor, v::Integer)
    println(vis.io, "close vertex: $v")
    return true
end

function examine_neighbor!(vis::LogGraphVisitor, u::Integer, v::Integer, ucolor::Int, vcolor::Int, ecolor::Int)
    println(vis.io, "examine neighbor: $u -> $v (ucolor = $ucolor, vcolor = $vcolor, edgecolor= $ecolor)")
    return true
end

function traverse_graph_withlog(
    g::AbstractGraph,
    alg::AbstractGraphVisitAlgorithm,
    sources,
    io::IO = STDOUT
)
    visitor = LogGraphVisitor(io)
    traverse_graph!(g, alg, sources, visitor)
end
