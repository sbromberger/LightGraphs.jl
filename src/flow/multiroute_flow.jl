"""
Abstract type that allows users to pass in their preferred Algorithm
"""
abstract AbstractMultirouteFlowAlgorithm

"""
Forces the multiroute_flow function to use the Kishimoto algorithm.
"""
type KishimotoAlgorithm <: AbstractMultirouteFlowAlgorithm
end

"""
Forces the multiroute_flow function to use the Extended Multiroute Flow algorithm.
"""
type ExtendedMultirouteFlowAlgorithm <: AbstractMultirouteFlowAlgorithm
end

# Method for Kishimoto algorithm
function multiroute_flow{T<:Number}(
  flow_graph::DiGraph,                   # the input graph
  source::Int,                           # the source vertex
  target::Int,                           # the target vertex
  capacity_matrix::AbstractArray{T,2},   # edge flow capacities
  flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
  mrf_algorithm::KishimotoAlgorithm,     # keyword argument for algorithm
  routes::Int                            # keyword argument for routes
  )
  return kishimoto(flow_graph, source, target, capacity_matrix, flow_algorithm, routes)
end

## Methods for Extended Multiroute Flow Algorithm
#1 When the breaking points are not already known
function multiroute_flow{T<:Number,R<:Number}(
  flow_graph::DiGraph,                            # the input graph
  source::Int,                                    # the source vertex
  target::Int,                                    # the target vertex
  capacity_matrix::AbstractArray{T,2},            # edge flow capacities
  flow_algorithm::AbstractFlowAlgorithm,          # keyword argument for algorithm
  mrf_algorithm::ExtendedMultirouteFlowAlgorithm, # keyword argument for algorithm
  routes::R                                       # keyword argument for routes
  )
  return emrf(flow_graph, source, target, capacity_matrix, flow_algorithm, routes)
end
#2 When the breaking points are already known
function multiroute_flow{T<:Number,R<:Number}(
  breakingpoints::Vector{Tuple{T,T,Int}},         # vector of breaking points
  routes::R,                                      # keyword argument for routes
  flow_algorithm::AbstractFlowAlgorithm =         # keyword argument for algorithm
      PushRelabelAlgorithm()
  )
  return intersection(breakingpoints,routes,flow_algorithm)
end

"""
Generic multiroute_flow function. Requires arguments:

I. When the main input is a network
- flow_graph::DiGraph                   # the input graph
- source::Int                           # the source vertex
- target::Int                           # the target vertex
- capacity_matrix::AbstractArray{T,2}   # edge flow capacities
- flow_algorithm::AbstractFlowAlgorithm # keyword argument for flow algorithm
- mrf_algorithm::AbstractFlowAlgorithm  # keyword argument for multiroute flow algorithm
- routes::R<:Number                     # keyword argument for the number of routes

The function defaults to the Push-relabel (classical flow) and Kishimoto (multiroute) algorithms. Alternatively, the algorithms to be used can also be specified through  keyword arguments. A default capacity of 1 is assumed for each link if no capacity matrix is provided.
The mrf_algorithm keyword is inforced to Extended Multiroute Flow in the following cases:
a) The number of routes is noninteger (however a max-flow )
b) The number of routes is 0 (the algorithm will output all the breaking points)

II. When the main input is a set of (breaking) points
  - breakingpoints::Vector{Tuple{T,T,Int}},      # vector of breaking points
  - routes::R<:Number,                           # keyword argument for routes
  - flow_algorithm::AbstractFlowAlgorithm        # keyword argument for flow algorithm

Except for I.2) (routes ≠ 0), all algorithms return a tuple with 1) the maximum flow and 2) the flow matrix. For the Boykov-Kolmogorov algorithm, the associated mincut is returned as a third output.

For I.2) (routes = 0), the set of breaking points of the multiroute flow is returned.

### Usage Example :
(please consult the  max_flow section for options about flow_algorithm and capacity_matrix)

```julia

# Create a flow-graph and a capacity matrix
flow_graph = DiGraph(8)
flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
    (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
    (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]
capacity_matrix = zeros(Int, 8, 8)
for e in flow_edges
    u, v, f = e
    add_edge!(flow_graph, u, v)
    capacity_matrix[u,v] = f
end

# Run default multiroute_flow with an integer number of routes = 2
f, F = multiroute_flow(flow_graph, 1, 8, capacity_matrix, routes = 2)

# Run default multiroute_flow with a noninteger number of routes = 1.5
f, F = multiroute_flow(flow_graph, 1, 8, capacity_matrix, routes = 1.5)

# Run default multiroute_flow for all the breaking points values
points = multiroute_flow(flow_graph, 1, 8, capacity_matrix)
# Then run multiroute flow algorithm for any positive number of routes
f, F = multiroute_flow(points, routes = 1.5)

# Run multiroute flow algorithm using Boykov-Kolmogorov algorithm as max_flow routine
f, F, labels = multiroute_flow(flow_graph,1,8,capacity_matrix,algorithm=BoykovKolmogorovAlgorithm(),routes=2)

```
"""
function multiroute_flow{T<:Number,R<:Number}(
  flow_graph::DiGraph,                   # the input graph
  source::Int,                           # the source vertex
  target::Int,                           # the target vertex
  capacity_matrix::AbstractArray{T,2} =  # edge flow capacities
    DefaultCapacity(flow_graph);
  flow_algorithm::AbstractFlowAlgorithm  =    # keyword argument for algorithm
    PushRelabelAlgorithm(),
  mrf_algorithm::AbstractMultirouteFlowAlgorithm  =    # keyword argument for algorithm
    KishimotoAlgorithm(),
  routes::R = 0              # keyword argument for number of routes (0 = all values)
  )
  if routes == 1 # a flow with a set of 1-disjoint path is a classical max-flow
    return maximum_flow(flow_graph, source, target, capacity_matrix, flow_algorithm)
  end
  if routes > maximum_flow(flow_graph,source,target,        # routes > λ → f = 0
    DefaultCapacity(flow_graph),algorithm=flow_algorithm)[1]
    n = nv(flow_graph)
    if flow_algorithm ≠ BoykovKolmogorovAlgorithm()
      return zero(T), zeros(T,n,n)
    end
    return zero(T), zeros(T,n,n), zeros(T,n)
  end

  if !(T<:AbstractFloat) # Capacities need to be Floats
    capacity_matrix = convert(AbstractArray{Float64,2}, capacity_matrix)
  end

  if routes == 0 # Ask for all possible values (breaking points)
    return emrf(flow_graph,source,target,capacity_matrix,flow_algorithm)
  end
  if R <: AbstractFloat # The number of routes is a float → EMRF
    return emrf(flow_graph,source,target,capacity_matrix,flow_algorithm,routes)
  end
  return multiroute_flow(flow_graph, source, target, # Other calls
    capacity_matrix, flow_algorithm, mrf_algorithm, routes)
end
