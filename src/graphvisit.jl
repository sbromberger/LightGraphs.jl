# Parts of this code were taken / derived from Graphs.jl:
# > Graphs.jl is licensed under the MIT License:
#
# > Copyright (c) 2012: John Myles White and other contributors.
# >
# > Permission is hereby granted, free of charge, to any person obtaining
# > a copy of this software and associated documentation files (the
# > "Software"), to deal in the Software without restriction, including
# > without limitation the rights to use, copy, modify, merge, publish,
# > distribute, sublicense, and/or sell copies of the Software, and to
# > permit persons to whom the Software is furnished to do so, subject to
# > the following conditions:
# >
# > The above copyright notice and this permission notice shall be
# > included in all copies or substantial portions of the Software.
# >
# > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# > EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# > MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# > NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# > LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# > OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# > WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# The concept and trivial implementation of graph visitors

abstract AbstractGraphVisitor

# trivial implementation

# invoked when a vertex v is encountered for the first time
# this function returns whether to continue search
discover_vertex!(vis::AbstractGraphVisitor, v) = true

# invoked when the algorithm is about to examine v's neighbors
open_vertex!(vis::AbstractGraphVisitor, v) = nothing

# invoked when a neighbor is discovered & examined
examine_neighbor!(vis::AbstractGraphVisitor, u, v, color::Int, ecolor::Int) = nothing

# invoked when an edge is discovered & examined
examine_edge!(vis::AbstractGraphVisitor, e, color::Int) = nothing

# invoked when all of v's neighbors have been examined
close_vertex!(vis::AbstractGraphVisitor, v) = nothing


type TrivialGraphVisitor <: AbstractGraphVisitor
end


# This is the common base for BreadthFirst and DepthFirst
abstract AbstractGraphVisitAlgorithm


###########################################################
#
#   General algorithms based on graph traversal
#
###########################################################

# List vertices by the order of being discovered

type VertexListVisitor <: AbstractGraphVisitor
    vertices::Vector{Int}

    function VertexListVisitor(n::Integer=0)
        vs = Int[]
        sizehint!(vs, n)
        new(vs)
    end
end

function discover_vertex!(visitor::VertexListVisitor, v::Int)
    push!(visitor.vertices, v)
    true
end

function visited_vertices(
    graph::AbstractGraph,
    alg::AbstractGraphVisitAlgorithm,
    sources)

    visitor = VertexListVisitor(nv(graph))
    traverse_graph(graph, alg, sources, visitor)
    visitor.vertices::Vector{Int}
end


# Print visit log

type LogGraphVisitor{S<:IO} <: AbstractGraphVisitor
    io::S
end

function discover_vertex!(vis::LogGraphVisitor, v::Int)
    println(vis.io, "discover vertex: $v")
    true
end

open_vertex!(vis::LogGraphVisitor, v::Int) = println(vis.io, "open vertex: $v")
close_vertex!(vis::LogGraphVisitor, v::Int) = println(vis.io, "close vertex: $v")

function examine_neighbor!(vis::LogGraphVisitor, u::Int, v::Int, vcolor::Int, ecolor::Int)
    println(vis.io, "examine neighbor: $u -> $v (vertexcolor = $vcolor, edgecolor= $ecolor)")
end

function examine_edge!(vis::LogGraphVisitor, e::Edge, color::Int)
    println(vis.io, "examine edge: $e")
end

function traverse_graph_withlog(g::AbstractGraph, alg::AbstractGraphVisitAlgorithm, sources::Vector{Int}, io::IO)
    visitor = LogGraphVisitor(io)
    traverse_graph(g, alg, sources, visitor)
end

traverse_graph_withlog(g::AbstractGraph, alg::AbstractGraphVisitAlgorithm,
    sources::Vector{Int}) = traverse_graph_withlog(g, alg, sources, STDOUT)
