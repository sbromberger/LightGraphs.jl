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

# Maximum adjacency visit / traversal


#################################################
#
#  Maximum adjacency visit
#
#################################################

type MaximumAdjacency <: AbstractGraphVisitAlgorithm
end

abstract AbstractMASVisitor <: AbstractGraphVisitor

function maximum_adjacency_visit_impl!(
  graph::AbstractGraph,	                      # the graph
  pq::Collections.PriorityQueue{Int, Float64},               # priority queue
  visitor::AbstractMASVisitor,                      # the visitor
  colormap::Vector{Int})                            # traversal status

  while !isempty(pq)
    u = Collections.dequeue!(pq)
    discover_vertex!(visitor, u)
    for v in fadj(graph, u)
      examine_edge!(visitor, Edge(u,v), 0)

      if haskey(pq,v)
          ed = visitor.edge_dists[u, v]
          if ed == zero(Float64)
              ed = 1.0
          end
        pq[v] += ed
      end
    end
    close_vertex!(visitor, u)
  end

end

function traverse_graph(
  graph::AbstractGraph,
  alg::MaximumAdjacency,
  s::Int,
  visitor::AbstractMASVisitor,
  colormap::Vector{Int})

  if VERSION > v"0.4.0-"
    pq = Collections.PriorityQueue(Int,Float64,Base.Order.Reverse)
  else
    pq = Collections.PriorityQueue{Int, Float64}(Base.Order.Reverse)
  end

  # Set number of visited neighbours for all vertices to 0
  for v in vertices(graph)
    pq[v] = zero(Float64)
  end

  @assert haskey(pq,s)
  @assert nv(graph) >= 2

  #Give the starting vertex high priority
  pq[s] = one(Float64)

  #start traversing the graph
  maximum_adjacency_visit_impl!(graph, pq, visitor, colormap)
end


#################################################
#
#  Visitors
#
#################################################


#################################################
#
#  Minimum Cut Visitor
#
#################################################

type MinCutVisitor <: AbstractMASVisitor
  graph::AbstractGraph
  parities::Vector{Bool}
  colormap::Vector{Int}
  bestweight::Float64
  cutweight::Float64
  visited::Integer
  edge_dists::AbstractArray{Float64, 2}
  vertices::Vector{Int}
end

function MinCutVisitor(graph::AbstractGraph, edge_dists::AbstractArray{Float64, 2})
  n = nv(graph)
  parities = falses(n)
  MinCutVisitor(graph, parities, zeros(n), Inf, 0.0, 0.0, edge_dists, Int[])
end

function discover_vertex!(vis::MinCutVisitor, v::Int)
  vis.parities[v] = false
  vis.colormap[v] = 1
  push!(vis.vertices,v)
  true
end

function examine_edge!(vis::MinCutVisitor, e::Edge, color::Int)
  vi = dst(e)
  ew = vis.edge_dists[src(e), dst(e)]
  if ew == zero(Float64)
      ew = 1.0
  end

  # if the target of e is already marked then decrease cutweight
  # otherwise, increase it

  if vis.colormap[vi] != color # here color is 0
    vis.cutweight -= ew
  else
    vis.cutweight += ew
  end
end

function close_vertex!(vis::MinCutVisitor, v::Int)
  vis.colormap[v] = 2
  vis.visited += 1

  if vis.cutweight < vis.bestweight && vis.visited < nv(vis.graph)
    vis.bestweight = vis.cutweight
    for u in vertices(vis.graph)
      vis.parities[u] = ( vis.colormap[u] == 2)
    end
  end
end

#################################################
#
#  MAS Visitor
#
#################################################

type MASVisitor <: AbstractMASVisitor
  io::IO
  vertices::Vector{Int}
  edge_dists::AbstractArray{Float64, 2}
  log::Bool
end

function discover_vertex!(visitor::MASVisitor, v::Int)
  push!(visitor.vertices,v)
  visitor.log ? println(visitor.io, "discover vertex: $v") : nothing
end

function examine_edge!(visitor::MASVisitor, e::Edge, color::Int)
  visitor.log ? println(visitor.io, " -- examine edge: $e") : nothing
end

function close_vertex!(visitor::MASVisitor, v::Int)
  visitor.log ? println(visitor.io, "close vertex: $v") : nothing
end

#################################################
#
#  Minimum Cut
#
#################################################

function mincut(
  graph::AbstractGraph,
  edge_dists::AbstractArray{Float64, 2},
  visitor = MinCutVisitor(graph, edge_dists),
  colormap = zeros(Int, nv(graph)))

  traverse_graph(graph, MaximumAdjacency(), first( vertices(graph) ), visitor, colormap)

  return( visitor.parities, visitor.bestweight)
end

function mincut(
  graph::AbstractGraph,
  edge_dists::AbstractArray{Float64, 2})

  visitor = MinCutVisitor(graph, edge_dists)
  colormap = zeros(Int, nv(graph))

  traverse_graph(graph, MaximumAdjacency(), first( vertices(graph) ), visitor, colormap)

  return( visitor.parities, visitor.bestweight)
end

function mincut(graph::AbstractGraph)
  nvg = nv(graph)
  mincut(graph,spzeros(nvg,nvg))
end

function maximum_adjacency_visit(graph::AbstractGraph, edge_dists::AbstractArray{Float64, 2}; log::Bool=false, io::IO=STDOUT)
  visitor = MASVisitor(io, Int[],edge_dists,log)
  traverse_graph(graph, MaximumAdjacency(), first(vertices(graph)), visitor, zeros(Int, nv(graph)))
  visitor.vertices
end

# function maximum_adjacency_visit(graph::AbstractGraph{V,E}, edge_weight_vec::Vector{W}; log::Bool=false, io::IO=STDOUT)
#   edge_weights = VectorEdgePropertyInspector(edge_weight_vec)
#   visitor = MASVisitor(io, V[],edge_weights,log)
#   traverse_graph(graph, MaximumAdjacency(), first(vertices(graph)), visitor, zeros(Int, num_vertices(graph)), W)
#   visitor.vertices
# end

function maximum_adjacency_visit(graph::AbstractGraph; log::Bool=false, io::IO=STDOUT)
  n = nv(graph)
  edge_dists = sparse(zeros(n,n))
  maximum_adjacency_visit(graph,edge_dists; log=log, io=io)
end
