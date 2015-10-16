"""Computes the maximum flow between the source and target vertexes in a flow
graph using [Edmond Karp's](https://en.wikipedia.org/wiki/Edmonds%E2%80%93Karp_algorithm)
algorithm. Returns the value of the maximum flow as well as the final flow matrix.

Use a default capacity of 1 when the capacity matrix isn't specified
"""

function maximum_flow{T<:Number}(
    flow_graph::LightGraphs.DiGraph,       # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2}=   # edge flow capacities
        DefaultDistance()
    )
    n = nv(flow_graph)                     # number of vertexes
    flow = 0
    flow_matrix = zeros(T, n, n)           # initialize flow matrix

    while true
        v, P, S = fetch_path(flow_graph, source, target, flow_matrix, capacity_matrix)

        if P == nothing                       # no more valid paths
            break
        else
            path = [v]                     # initialize path
            sizehint!(path, n)

            u = v
            while u!=source                # trace path from v to source
                u = P[u]
                push!(path, u)
            end
            reverse!(path)

            u = v                          # trace path from v to target
            while u!=target
                u = S[u]
                push!(path, u)
            end
                                           # augment flow along path
            flow += augment_path!(path, flow_matrix, capacity_matrix)
        end
    end

    return flow, flow_matrix
end

"""Calculates the amount by which flow can be augmented in the given path.
Augments the flow and returns the augment value."""

function augment_path!{T<:Number}(
    path::Vector{Int},                     # input path
    flow_matrix::AbstractArray{T,2},       # the current flow matrix
    capacity_matrix::AbstractArray{T,2}    # edge flow capacities
    )
    augment = typemax(T)                   # initialize augment
    for i in 1:length(path)-1              # calculate min capacity along path
        u = path[i]
        v = path[i+1]
        augment = min(augment,capacity_matrix[u,v] - flow_matrix[u,v])
    end

    for i in 1:length(path)-1              # augment flow along path
        u = path[i]
        v = path[i+1]
        flow_matrix[u,v] += augment
        flow_matrix[v,u] -= augment
    end

    return augment
end

"""Uses Bidirectional BFS to look for augmentable-paths. Returns the vertex where
the two BFS searches intersect, the Parent table of the path as well as the
Successor table of the path found."""

function fetch_path{T<:Number}(
    flow_graph::LightGraphs.DiGraph,       # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    flow_matrix::AbstractArray{T,2},       # the current flow matrix
    capacity_matrix::AbstractArray{T,2}    # edge flow capacities
    )
    n = nv(flow_graph)

    P = [-1 for i in 1:n]                  # parent table of path
    P[source] = -2

    S = [-1 for i in 1:n]                  # successor table of path
    S[target] = -2

    Q_f = [source]                         # forward queue
    sizehint!(Q_f, n)

    Q_r = [target]                         # reverse queue
    sizehint!(Q_r, n)

    while true

        if length(Q_f) <= length(Q_r)
            u = pop!(Q_f)
            for v in fadj(flow_graph, u)
                if capacity_matrix[u,v] - flow_matrix[u,v] > 0 && P[v] == -1
                    P[v] = u
                    if S[v] == -1
                        unshift!(Q_f, v)
                    else
                        return v, P, S
                    end
                end
            end

            if length(Q_f) == 0
                return 0, nothing, nothing # No paths to target
            end
        else
            v = pop!(Q_r)
            for u in badj(flow_graph, v)
                if capacity_matrix[u,v] - flow_matrix[u,v] > 0 && S[u] == -1
                    S[u] = v
                    if P[u] == -1
                        unshift!(Q_r, u)
                    else
                        return u, P, S
                    end
                end

            end

            if length(Q_r) == 0
                return 0, nothing, nothing # No paths to source
            end
        end
    end
end
