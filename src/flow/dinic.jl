"""
Computes the maximum flow between the source and target vertexes in a flow
graph using [Dinic\'s Algorithm](https://en.wikipedia.org/wiki/Dinic%27s_algorithm)
Returns the value of the maximum flow as well as the final flow matrix.

Use a default capacity of 1 when the capacity matrix isn\'t specified.

Requires arguments:
residual_graph::DiGraph                # the input graph
source::Integer                        # the source vertex
target::Integer                        # the target vertex
capacity_matrix::AbstractArray{T,2}    # edge flow capacities
"""
function dinic_impl end
@traitfn function dinic_impl{G<:AbstractGraph; IsDirected{G}}(
    residual_graph::G,               # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix    # edge flow capacities
    )
    n = nv(residual_graph)                     # number of vertexes
    T = eltype(capacity_matrix)
    flow_matrix = zeros(T, n, n)           # initialize flow matrix
    P = zeros(Int, n)                      # Sharable parent vector

    flow = 0

    while true
        augment = blocking_flow!(residual_graph, source, target, capacity_matrix, flow_matrix, P)
        augment == 0 && break
        flow += augment
    end
    return flow, flow_matrix
end



"""
Uses BFS to identify a blocking flow in
the input graph and then backtracks from the target to the source, aumenting flow
along all possible paths.

Requires arguments:
residual_graph::DiGraph                # the input graph
source::Integer                        # the source vertex
target::Integer                        # the target vertex
capacity_matrix::AbstractArray{T,2}    # edge flow capacities
flow_matrix::AbstractArray{T,2}        # the current flow matrix
P::AbstractVector{Int}                 # Parent vector to store Level Graph
"""
function blocking_flow! end
@traitfn function blocking_flow!{G<:AbstractGraph; IsDirected{G}}(
    residual_graph::G,               # the input graph
    source::Integer,                           # the source vertex
    target::Integer,                           # the target vertex
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    flow_matrix::AbstractMatrix,       # the current flow matrix
    P::AbstractVector{Int}                 # Parent vector to store Level Graph
    )
    n = nv(residual_graph)                     # number of vertexes
    T = eltype(capacity_matrix)
    fill!(P, -1)
    P[source] = -2

    Q = [source]
    sizehint!(Q, n)

    while length(Q) > 0                   # Construct the Level Graph using BFS
        u = pop!(Q)
        for v in out_neighbors(residual_graph, u)
            if P[v] == -1 && capacity_matrix[u,v] > flow_matrix[u,v]
                P[v] = u
                unshift!(Q, v)
            end
        end
    end

    P[target] == -1 && return 0                    # BFS couldn't reach the target

    total_flow = 0

    for bv in in_neighbors(residual_graph, target)    # Trace all possible routes to source
        flow = typemax(T)
        v = target
        u = bv
        while v != source
            if u == -1                    # Vertex unreachable from source
                flow = 0
                break
            else
                flow = min(flow, capacity_matrix[u,v] - flow_matrix[u,v])
                v = u
                u = P[u]
            end
        end

        flow == 0 && continue                      # Flow cannot be augmented along path

        v = target
        u = bv
        while v != source             # Augment flow along path
            flow_matrix[u,v] += flow
            flow_matrix[v,u] -= flow
            v = u
            u = P[u]
        end

        total_flow += flow
    end
    return total_flow
end

blocking_flow!(
    residual_graph::AbstractGraph,               # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    flow_matrix::AbstractMatrix,       # the current flow matrix
    ) = blocking_flow!(
            residual_graph,
            source,
            target,
            capacity_matrix,
            flow_matrix,
            zeros(Int, nv(residual_graph)))
