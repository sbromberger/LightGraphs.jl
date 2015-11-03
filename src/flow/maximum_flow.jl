"""
Abstract type that allows users to pass in their preferred Algorithm
"""
abstract AbstractFlowAlgorithm

"""
Forces the maximum_flow function to use Edmonds Karp\'s maximum flow algorithm.
"""
type EdmondsKarpAlgorithm <: AbstractFlowAlgorithm
end

"""
Forces the maximum_flow function to use Dinic\'s maximum flow algorithm.
"""
type DinicAlgorithm <: AbstractFlowAlgorithm
end

"""
Forces the maximum_flow function to use the Push-Relabel maximum flow algorithm.
"""
type PushRelabelAlgorithm <: AbstractFlowAlgorithm
end

"""
Type that returns 1 if a forward edge exists, and 0 otherwise
"""

type DefaultCapacity <: AbstractArray{Int, 2}
    flow_graph::LightGraphs.DiGraph
    nv::Int
    DefaultCapacity(flow_graph::LightGraphs.DiGraph) = new(flow_graph, nv(flow_graph))
end

getindex(d::DefaultCapacity, s::Int, t::Int) = if has_edge(d.flow_graph, s , t) 1 else 0 end
size(d::DefaultCapacity) = (d.nv, d.nv)
transpose(d::DefaultCapacity) = DefaultCapacity(reverse(d.flow_graph))
ctranspose(d::DefaultCapacity) = DefaultCapacity(reverse(d.flow_graph))

"""
Constructs a residual graph for the input flow graph. Creates a new graph instead
of modifying the input flow graph.

The residual graph comprises of the same Vertex list, but ensures that for each
edge (u,v), (v,u) also exists in the graph. (to allow flow in the reverse direction).

If only the forward edge exists, a reverse edge is created with capacity 0. If both
forward and reverse edges exist, their capacities are left unchanged. Since the capacities
in DefaultDistance cannot be changed, an array of ones is created. Returns the
residual graph and the modified capacity_matrix (when DefaultDistance is used.)

Requires arguments:
flow_graph::LightGraphs.DiGraph,        # the input graph
capacity_matrix::AbstractArray{T,2}     # input capacity matrix
"""

function residual(
    flow_graph::LightGraphs.DiGraph         # the input graph
    )

    n = nv(flow_graph)
    residual_graph = copy(flow_graph)       # make a copy of the input graph
    for (u,v) in edges(flow_graph)
        if !has_edge(flow_graph, v, u)      # create reverse edge
            add_edge!(residual_graph, v, u)
        end
    end

    return residual_graph
end

"""
Method for Edmonds Karp\'s Algorithm
"""

function maximum_flow{T<:Number}(
    flow_graph::LightGraphs.DiGraph,       # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2},   # edge flow capacities
    algorithm::EdmondsKarpAlgorithm         # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return edmonds_karp_impl(residual_graph, source, target, capacity_matrix)
end

"""
Method for Push-Relabel Algorithm
"""

function maximum_flow{T<:Number}(
    flow_graph::LightGraphs.DiGraph,       # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2},   # edge flow capacities
    algorithm::PushRelabelAlgorithm        # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return push_relabel(residual_graph, source, target, capacity_matrix)
end

"""
Method for Dinic\'s algorithm
"""

function maximum_flow{T<:Number}(
    flow_graph::LightGraphs.DiGraph,       # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2},   # edge flow capacities
    algorithm::DinicAlgorithm             # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return dinic_impl(residual_graph, source, target, capacity_matrix)
end

"""
Generic maximum_flow function that can use one of the three flow algorithms:
1. Endmond-Karp\'s algorithm: O(VE^2).
2. Dinic\'s blocking-flow algorithm: O(V^2E)
3. Push-Relabel algorithm: O(V^3).

Requires arguments:
flow_graph::LightGraphs.DiGraph       # the input graph
source::Int                           # the source vertex
target::Int                           # the target vertex
capacity_matrix::AbstractArray{T,2}   # edge flow capacities
;
algorithm::AbstractFlowAlgorithm      # keyword argument for algorithm
"""

function maximum_flow{T<:Number}(
    flow_graph::LightGraphs.DiGraph,       # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2} =  # edge flow capacities
        DefaultCapacity(flow_graph);
    algorithm::AbstractFlowAlgorithm  =     # keyword argument for algorithm
        PushRelabelAlgorithm()
    )
    return maximum_flow(flow_graph, source, target, capacity_matrix, algorithm)
end
