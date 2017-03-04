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
typealias AbstractVertexMap{T} Union{AbstractVector{T},Associative{Int, T}}

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

type VertexListVisitor <: AbstractGraphVisitor
    vertices::Vector{Int}

    function VertexListVisitor(n::Integer=0)
        vs = Vector{Int}()
        sizehint!(vs, n)
        new(vs)
    end
end

function discover_vertex!(visitor::VertexListVisitor, v::Int)
    push!(visitor.vertices, v)
    return true
end

function visited_vertices(
    graph::AbstractGraph,
    alg::AbstractGraphVisitAlgorithm,
    sources)

    visitor = VertexListVisitor(nv(graph))
    traverse_graph!(graph, alg, sources, visitor)
    visitor.vertices::Vector{Int}
end


# Print visit log

type LogGraphVisitor{S<:IO} <: AbstractGraphVisitor
    io::S
end

function discover_vertex!(vis::LogGraphVisitor, v::Int)
    println(vis.io, "discover vertex: $v")
    return true
end

function open_vertex!(vis::LogGraphVisitor, v::Int)
    println(vis.io, "open vertex: $v")
    return true
end

function close_vertex!(vis::LogGraphVisitor, v::Int)
    println(vis.io, "close vertex: $v")
    return true
end

function examine_neighbor!(vis::LogGraphVisitor, u::Int, v::Int, ucolor::Int, vcolor::Int, ecolor::Int)
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
