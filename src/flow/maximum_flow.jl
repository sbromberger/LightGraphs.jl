"""AbstractFlowAlgorithm
Abstract type that allows users to pass in their preferred Algorithm
"""
abstract AbstractFlowAlgorithm

"""EdmundKarpAlgorithm
Forces the maximum_flow function to use Edmund Karp's maximum flow algorithm.
"""
type EdmundKarpAlgorithm <: AbstractFlowAlgorithm
end

"""DinitzAlgorithm
Forces the maximum_flow function to use Dinitz's maximum flow algorithm.
"""
type DinitzAlgorithm <: AbstractFlowAlgorithm
end

"""PushRelabelAlgorithm
Forces the maximum_flow function to use the Push-Relabel maximum flow algorithm.
"""
type PushRelabelAlgorithm <: AbstractFlowAlgorithm
end

"""residual
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

function residual{T<:Number}(
    flow_graph::LightGraphs.DiGraph,        # the input graph
    capacity_matrix::AbstractArray{T,2}     # input capacity matrix
    )
    n = nv(flow_graph)

    residual_graph = copy(flow_graph)       # make a copy of the input graph

    if typeof(capacity_matrix) == DefaultDistance
        capacity_matrix = zeros(T, n, n)    # create a new capacity matrix
        for (u,v) in edges(flow_graph)
            capacity_matrix[u,v] = 1
            if !has_edge(flow_graph, v, u)  # create reverse edge
                add_edge!(residual_graph, v, u)
            end
        end
    else
        for (u,v) in edges(flow_graph)
            if !has_edge(flow_graph, v, u) # create reverse edge
                add_edge!(residual_graph, v, u)
            end
        end
    end

    return residual_graph, capacity_matrix
end

"""Generic maximum_flow function that can use one of the three flow algorithms:
1. Endmond Karp's algorithm: O(VE^2).
2. Dinic's blocking-flow algorithm: O(V^2E)
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
    capacity_matrix::AbstractArray{T,2}=   # edge flow capacities
        DefaultDistance();
    algorithm::AbstractFlowAlgorithm =     # keyword argument for algorithm
        EdmundKarpAlgorithm()
    )
    residual_graph, capacity_matrix = residual(flow_graph, capacity_matrix)

    if typeof(algorithm) == EdmundKarpAlgorithm
        return edmund_karp_impl(residual_graph, source, target, capacity_matrix)
    elseif typeof(algorithm) == DinitzAlgorithm
        return dinitz_impl(residual_graph, source, target, capacity_matrix)
    elseif typeof(algorithm) == PushRelabelAlgorithm
        return push_relabel(residual_graph, source, target, capacity_matrix)
    end

    return push_relabel(residual_graph, source, target, capacity_matrix)
end
