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
type ExtendedMultirouteFlowAlgorithm <: AbstractFlowAlgorithm
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

function multiroute_flow{T<:Number}(
  flow_graph::DiGraph,                   # the input graph
  source::Int,                           # the source vertex
  target::Int,                           # the target vertex
  capacity_matrix::AbstractArray{T,2} =  # edge flow capacities
    DefaultCapacity(flow_graph);
  flow_algorithm::AbstractFlowAlgorithm  =    # keyword argument for algorithm
    PushRelabelAlgorithm(),
  mrf_algorithm::AbstractMultirouteFlowAlgorithm  =    # keyword argument for algorithm
    KishimotoAlgorithm(),
  routes::Int = 1               # keyword argument for number of routes
  )
  if routes == 1 # a flow with a set of 1-disjoint path is a classical max-flow
    return maximum_flow(flow_graph, source, target, capacity_matrix, flow_algorithm)
  end
  if routes > maximum_flow(flow_graph,source,target)[1]
    n = nv(flow_graph)
    return 0, zeros(T, n, n)
  end
  return multiroute_flow(flow_graph, source, target, capacity_matrix, flow_algorithm, mrf_algorithm, routes)
end

# Kishimoto algorithm
function kishimoto{T<:Number}(
  flow_graph::DiGraph,                   # the input graph
  source::Int,                           # the source vertex
  target::Int,                           # the target vertex
  capacity_matrix::AbstractArray{T,2},   # edge flow capacities
  flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
  routes::Int                            # keyword argument for routes
  )
  # Capacities need to be Floats
  if !(T<:AbstractFloat)
    capacity_matrix = convert(AbstractArray{Float64,2}, capacity_matrix)
  end

  # Initialisation
  flow, F = maximum_flow(flow_graph, source, target,
         capacity_matrix, algorithm = flow_algorithm)
  restriction = flow / routes

  flow, F = maximum_flow(flow_graph, source, target, capacity_matrix,
            algorithm = flow_algorithm, restriction = restriction)

  # Loop
  i = 1
  while flow ≉ routes * restriction && flow < routes * restriction
    restriction = (flow - i * restriction) / (routes - i)
    i = i + 1
    flow, F = maximum_flow(flow_graph, source, target, capacity_matrix,
              algorithm = flow_algorithm, restriction = restriction)
  end

  # End
  return flow, F
end
