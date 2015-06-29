# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Maximum adjacency visit / traversal


#################################################
#
#  Maximum adjacency visit
#
#################################################

type MaximumAdjacency <: AbstractGraphVisitAlgorithm
end

abstract AbstractMASVisitor <: AbstractGraphVisitor

function maximum_adjacency_visit_impl!{T}(
  graph::AbstractGeneralGraph,	                      # the graph
  pq::Collections.PriorityQueue{Int, T},               # priority queue
  visitor::AbstractMASVisitor,                      # the visitor
  colormap::Vector{Int})                            # traversal status

  while !isempty(pq)
    u = Collections.dequeue!(pq)
    discover_vertex!(visitor, u)
    for v in fadj(graph, u)
      examine_edge!(visitor, Edge(u,v), 0)

      if haskey(pq,v)
          ed = visitor.distmx[u, v]
          if ed == zero(T)
              ed = 1.0
          end
        pq[v] += ed
      end
    end
    close_vertex!(visitor, u)
  end

end

function traverse_graph(
  graph::AbstractGeneralGraph,
  T::DataType,
  alg::MaximumAdjacency,
  s::Int,
  visitor::AbstractMASVisitor,
  colormap::Vector{Int})

  if VERSION > v"0.4.0-"
    pq = Collections.PriorityQueue(Int,T,Base.Order.Reverse)
  else
    pq = Collections.PriorityQueue{Int, T}(Base.Order.Reverse)
  end

  # Set number of visited neighbours for all vertices to 0
  for v in vertices(graph)
    pq[v] = zero(T)
  end

  @assert haskey(pq,s)
  @assert nv(graph) >= 2

  #Give the starting vertex high priority
  pq[s] = one(T)

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

type MinCutVisitor{T} <: AbstractMASVisitor
  graph::AbstractGeneralGraph
  parities::AbstractArray{Bool,1}
  colormap::Vector{Int}
  bestweight::T
  cutweight::T
  visited::Integer
  distmx::AbstractArray{T, 2}
  vertices::Vector{Int}
end

function MinCutVisitor{T}(graph::AbstractGeneralGraph, distmx::AbstractArray{T, 2})
  n = nv(graph)
  parities = falses(n)
  MinCutVisitor(graph, parities, zeros(Int,n), typemax(T), zero(T), zero(Int), distmx, Int[])
end

function discover_vertex!(vis::MinCutVisitor, v::Int)
  vis.parities[v] = false
  vis.colormap[v] = 1
  push!(vis.vertices,v)
  true
end

function examine_edge!(vis::MinCutVisitor, e::Edge, color::Int)
  vi = dst(e)
  ew = vis.distmx[src(e), dst(e)]

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

type MASVisitor{T} <: AbstractMASVisitor
  io::IO
  vertices::Vector{Int}
  distmx::AbstractArray{T, 2}
  log::Bool
end

function discover_vertex!{T}(visitor::MASVisitor{T}, v::Int)
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

# function mincut{T}(
#   graph::AbstractGeneralGraph,
#   distmx::AbstractArray{T, 2},
#   visitor = MinCutVisitor(graph, distmx),
#   colormap = zeros(Int, nv(graph)))
#
#   traverse_graph(graph, MaximumAdjacency(), first( vertices(graph) ), visitor, colormap)
#
#   return( visitor.parities, visitor.bestweight)
# end

function mincut{T}(
  graph::AbstractGeneralGraph,
  distmx::AbstractArray{T, 2})

  visitor = MinCutVisitor(graph, distmx)
  colormap = zeros(Int, nv(graph))

  traverse_graph(graph, T, MaximumAdjacency(), first( vertices(graph) ), visitor, colormap)

  return( visitor.parities, visitor.bestweight)
end

function mincut(graph::AbstractGeneralGraph)
  nvg = nv(graph)
  mincut(graph,DefaultDistance())
end

function maximum_adjacency_visit{T}(graph::AbstractGeneralGraph, distmx::AbstractArray{T, 2}; log::Bool=false, io::IO=STDOUT)
  visitor = MASVisitor(io, Int[],distmx,log)
  traverse_graph(graph, T, MaximumAdjacency(), first(vertices(graph)), visitor, zeros(Int, nv(graph)))
  visitor.vertices
end

function maximum_adjacency_visit(graph::AbstractGeneralGraph; log::Bool=false, io::IO=STDOUT)
  n = nv(graph)
  distmx = sparse(zeros(n,n))
  maximum_adjacency_visit(graph,distmx; log=log, io=io)
end
