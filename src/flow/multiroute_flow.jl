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

# Methods when the number of routes is more than the connectivity
# 1) When using Boykov-Kolmogorov as a flow subroutine
# 2) Other flow algorithm
function empty_flow{T<:Real}(
  capacity_matrix::AbstractMatrix{T},     # edge flow capacities
  flow_algorithm::BoykovKolmogorovAlgorithm # keyword argument for algorithm
  )
  n = size(capacity_matrix, 1)
  return zero(T), zeros(T, n, n), zeros(T, n)
end
# 2) Other flow algorithm
function empty_flow{T<:Real}(
  capacity_matrix::AbstractMatrix{T},     # edge flow capacities
  flow_algorithm::AbstractFlowAlgorithm     # keyword argument for algorithm
  )
  n = size(capacity_matrix, 1)
  return zero(T), zeros(T, n, n)
end

# Method for Kishimoto algorithm
@traitfn function multiroute_flow{G<:AbstractGraph; IsDirected{G}}(
  flow_graph::G,                   # the input graph
  source::Integer,                       # the source vertex
  target::Integer,                       # the target vertex
  capacity_matrix::AbstractMatrix,  # edge flow capacities
  flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
  mrf_algorithm::KishimotoAlgorithm,     # keyword argument for algorithm
  routes::Int                            # keyword argument for routes
  )
  return kishimoto(flow_graph, source, target, capacity_matrix, flow_algorithm, routes)
end

## Methods for Extended Multiroute Flow Algorithm
#1 When the breaking points are not already known
@traitfn function multiroute_flow{G<:AbstractGraph; IsDirected{G}}(
  flow_graph::G,                            # the input graph
  source::Integer,                                # the source vertex
  target::Integer,                                # the target vertex
  capacity_matrix::AbstractMatrix,           # edge flow capacities
  flow_algorithm::AbstractFlowAlgorithm,          # keyword argument for algorithm
  mrf_algorithm::ExtendedMultirouteFlowAlgorithm, # keyword argument for algorithm
  routes::Real                                       # keyword argument for routes
  )
  return emrf(flow_graph, source, target, capacity_matrix, flow_algorithm, routes)
end
#2 When the breaking points are already known
#2-a Output: flow value (paired with the associated restriction)
function multiroute_flow{T<:Real, R<:Real}(
  breakingpoints::Vector{Tuple{T, T, Int}},       # vector of breaking points
  routes::R                                       # keyword argument for routes
  )
  return intersection(breakingpoints, routes)
end
#2-b Output: flow value, flows(, labels)
function multiroute_flow{T1<:Real, R<:Real}(
  breakingpoints::AbstractVector{Tuple{T1, T1, Int}}, # vector of breaking points
  routes::R,                                # keyword argument for routes
  flow_graph::AbstractGraph,                      # the input graph
  source::Integer,                          # the source vertex
  target::Integer,                          # the target vertex
  capacity_matrix::AbstractMatrix =   # edge flow capacities
    DefaultCapacity(flow_graph);
  flow_algorithm::AbstractFlowAlgorithm  =  # keyword argument for algorithm
    PushRelabelAlgorithm()
  )
  x, f = intersection(breakingpoints, routes)
  T2 = eltype(capacity_matrix)
  # For other cases, capacities need to be Floats
  if !(T2<:AbstractFloat)
    capacity_matrix = convert(AbstractArray{Float64, 2}, capacity_matrix)
  end

  return maximum_flow(flow_graph, source, target, capacity_matrix,
                      algorithm = flow_algorithm, restriction = x)
end

"""
The generic multiroute_flow function will output three kinds of results:

- When the number of routes is 0 or non-specified, the set of breaking points of
the multiroute flow is returned.
- When the input is limited to a set of breaking points and a route value k,
only the value of the k-route flow is returned
- Otherwise, a tuple with 1) the maximum flow and 2) the flow matrix. When the
max-flow subroutine is the Boykov-Kolmogorov algorithm, the associated mincut is
returned as a third output.

When the input is a network, it requires the following arguments:

- flow_graph::DiGraph                   # the input graph
- source::Integer                       # the source vertex
- target::Integer                       # the target vertex
- capacity_matrix::AbstractArray{T, 2}  # edge flow capacities with T<:Real
- flow_algorithm::AbstractFlowAlgorithm # keyword argument for flow algorithm
- mrf_algorithm::AbstractFlowAlgorithm  # keyword argument for multiroute flow algorithm
- routes::R<:Real                       # keyword argument for the number of routes

When the input is only the set of (breaking) points and the number of route,
it requires the following arguments:

- breakingpoints::Vector{Tuple{T, T, Int}},    # vector of breaking points
- routes::R<:Real,                             # number of routes

When the input is the set of (breaking) points, the number of routes,
and the network descriptors, it requires the following arguments:

- breakingpoints::Vector{Tuple{T1, T1, Int}} # vector of breaking points (T1<:Real)
- routes::R<:Real                            # number of routes
- flow_graph::DiGraph                        # the input graph
- source::Integer                            # the source vertex
- target::Integer                            # the target vertex
- capacity_matrix::AbstractArray{T2, 2}      # optional edge flow capacities (T2<:Real)
- flow_algorithm::AbstractFlowAlgorithm      # keyword argument for algorithm

The function defaults to the Push-relabel (classical flow) and Kishimoto
(multiroute) algorithms. Alternatively, the algorithms to be used can also
be specified through  keyword arguments. A default capacity of 1 is assumed
for each link if no capacity matrix is provided.

The mrf_algorithm keyword is inforced to Extended Multiroute Flow
in the following cases:

- The number of routes is non-integer
- The number of routes is 0 or non-specified

### Usage Example :
(please consult the  max_flow section for options about flow_algorithm
and capacity_matrix)

```julia

# Create a flow-graph and a capacity matrix
flow_graph = DiGraph(8)
flow_edges = [
    (1, 2, 10), (1, 3, 5),  (1, 4, 15), (2, 3, 4),  (2, 5, 9),
    (2, 6, 15), (3, 4, 4),  (3, 6, 8),  (4, 7, 16), (5, 6, 15),
    (5, 8, 10), (6, 7, 15), (6, 8, 10), (7, 3, 6),  (7, 8, 10)
]
capacity_matrix = zeros(Int, 8, 8)
for e in flow_edges
    u, v, f = e
    add_edge!(flow_graph, u, v)
    capacity_matrix[u, v] = f
end

# Run default multiroute_flow with an integer number of routes = 2
f, F = multiroute_flow(flow_graph, 1, 8, capacity_matrix, routes = 2)

# Run default multiroute_flow with a noninteger number of routes = 1.5
f, F = multiroute_flow(flow_graph, 1, 8, capacity_matrix, routes = 1.5)

# Run default multiroute_flow for all the breaking points values
points = multiroute_flow(flow_graph, 1, 8, capacity_matrix)
# Then run multiroute flow algorithm for any positive number of routes
f, F = multiroute_flow(points, 1.5)
f = multiroute_flow(points, 1.5, valueonly = true)

# Run multiroute flow algorithm using Boykov-Kolmogorov algorithm as max_flow routine
f, F, labels = multiroute_flow(flow_graph, 1, 8, capacity_matrix,
               algorithm = BoykovKolmogorovAlgorithm(), routes = 2)

```
"""
function multiroute_flow{R<:Real}(
  flow_graph::AbstractGraph,                    # the input graph
  source::Integer,                        # the source vertex
  target::Integer,                        # the target vertex
  capacity_matrix::AbstractMatrix =  # edge flow capacities
    DefaultCapacity(flow_graph);
  flow_algorithm::AbstractFlowAlgorithm  =    # keyword argument for algorithm
    PushRelabelAlgorithm(),
  mrf_algorithm::AbstractMultirouteFlowAlgorithm  =    # keyword argument for algorithm
    KishimotoAlgorithm(),
  routes::R = 0              # keyword argument for number of routes (0 = all values)
  )

  # a flow with a set of 1-disjoint pathes is a classical max-flow
  (routes == 1) &&
  return maximum_flow(flow_graph, source, target, capacity_matrix, flow_algorithm)

  # routes > λ (connectivity) → f = 0
  λ = maximum_flow(flow_graph, source, target, DefaultCapacity(flow_graph),
                                             algorithm = flow_algorithm)[1]
  (routes > λ) && return empty_flow(capacity_matrix, flow_algorithm)

  # For other cases, capacities need to be Floats
  T = eltype(capacity_matrix)
  if !(T<:AbstractFloat)
    capacity_matrix = convert(AbstractMatrix{Float64}, capacity_matrix)
  end

  # Ask for all possible values (breaking points)
  (routes == 0) &&
    return emrf(flow_graph, source, target, capacity_matrix, flow_algorithm)
  # The number of routes is a float → EMRF
  (R <: AbstractFloat) &&
    return emrf(flow_graph, source, target, capacity_matrix, flow_algorithm, routes)
    
  # Other calls
  return multiroute_flow(flow_graph, source, target, capacity_matrix,
                               flow_algorithm, mrf_algorithm, routes)
end
