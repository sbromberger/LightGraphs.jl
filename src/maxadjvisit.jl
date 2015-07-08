# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Maximum adjacency visit / traversal


#################################################
#
#  Maximum adjacency visit
#
#################################################

type MaximumAdjacency <: SimpleGraphVisitAlgorithm
end

abstract AbstractMASVisitor <: SimpleGraphVisitor

function maximum_adjacency_visit_impl!{T}(
  graph::SimpleGraph,	                      # the graph
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
  graph::SimpleGraph,
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
  graph::SimpleGraph
  parities::AbstractArray{Bool,1}
  colormap::Vector{Int}
  bestweight::T
  cutweight::T
  visited::Integer
  distmx::AbstractArray{T, 2}
  vertices::Vector{Int}
end

function MinCutVisitor{T}(graph::SimpleGraph, distmx::AbstractArray{T, 2})
  n = nv(graph)
  MinCutVisitor(
    graph,
    falses(n),
    zeros(Int,n),
    typemax(T),
    zero(T),
    zero(Int),
    distmx,
    @compat(Vector{Int}())
)
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


function mincut{T}(
  graph::SimpleGraph,
  distmx::AbstractArray{T, 2}
 )

  visitor = MinCutVisitor(graph, distmx)
  colormap = zeros(Int, nv(graph))

  traverse_graph(graph, T, MaximumAdjacency(), 1, visitor, colormap)

  return( visitor.parities, visitor.bestweight)
end

mincut(graph::SimpleGraph) = mincut(graph,DefaultDistance())


function maximum_adjacency_visit{T}(graph::SimpleGraph, distmx::AbstractArray{T, 2}, log::Bool, io::IO)
  visitor = MASVisitor(io, Int[],distmx,log)
  traverse_graph(graph, T, MaximumAdjacency(), 1, visitor, zeros(Int, nv(graph)))
  return visitor.vertices
end

maximum_adjacency_visit(graph::SimpleGraph) = maximum_adjacency_visit(
    graph,
    DefaultDistance(),
    false,
    STDOUT
)
