"""
    edmonds_karp_impl(residual_graph, source, target, capacity_matrix)

Compute the maximum flow in flow graph `residual_graph` between `source` and
`target` and capacities defined in `capacity_matrix` using the
[Edmonds-Karp algorithm](https://en.wikipedia.org/wiki/Edmondss%E2%80%93Karp_algorithm).
Return the value of the maximum flow as well as the final flow matrix.
"""
function edmonds_karp_impl end
@traitfn function edmonds_karp_impl(
    residual_graph::::IsDirected,               # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix    # edge flow capacities
    )
    T = eltype(capacity_matrix)
    n = nv(residual_graph)                     # number of vertexes
    flow = 0
    flow_matrix = zeros(T, n, n)           # initialize flow matrix
    P = zeros(Int, n)
    S = zeros(Int, n)
    while true
        fill!(P, -1)
        fill!(S, -1)
        v, P, S, flag = fetch_path!(residual_graph, source, target, flow_matrix, capacity_matrix, P, S)

        if flag != 0                       # no more valid paths
            break
        else
            path = [Int(v)]                     # initialize path
            sizehint!(path, n)

            u = v
            while u != source                # trace path from v to source
                u = P[u]
                push!(path, u)
            end
            reverse!(path)

            u = v                          # trace path from v to target
            while u != target
                u = S[u]
                push!(path, Int(u))
            end
            # augment flow along path
            flow += augment_path!(path, flow_matrix, capacity_matrix)
        end
    end

    return flow, flow_matrix
end

"""
    augment_path!(path, flow_matrix, capacity_matrix)

Calculate the amount by which flow can be augmented in the given path.
Augment the flow and returns the augment value.
"""
function augment_path!(
    path::Vector{Int},                     # input path
    flow_matrix::AbstractMatrix,       # the current flow matrix
    capacity_matrix::AbstractMatrix    # edge flow capacities
    )
    T = eltype(flow_matrix)
    augment = typemax(T)                   # initialize augment
    for i in 1:(length(path) - 1)              # calculate min capacity along path
        u = path[i]
        v = path[i + 1]
        augment = min(augment, capacity_matrix[u, v] - flow_matrix[u, v])
    end

    for i in 1:(length(path) - 1)              # augment flow along path
        u = path[i]
        v = path[i + 1]
        flow_matrix[u, v] += augment
        flow_matrix[v, u] -= augment
    end

    return augment
end

"""
    fetch_path!(residual_graph, source, target, flow_matrix, capacity_matrix, P, S)

Like `fetch_path`, but requires preallocated parent vector `P` and successor
vector `S`.
"""
function fetch_path! end
@traitfn function fetch_path!(
    residual_graph::::IsDirected,               # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    flow_matrix::AbstractMatrix,       # the current flow matrix
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    P::Vector{Int},                        # parent table of path init to -1s
    S::Vector{Int}                         # successor table of path init to -1s
    )
    n = nv(residual_graph)

    P[source] = -2
    S[target] = -2

    Q_f = [source]                         # forward queue
    sizehint!(Q_f, n)

    Q_r = [target]                         # reverse queue
    sizehint!(Q_r, n)

    while true
        if length(Q_f) <= length(Q_r)
            u = pop!(Q_f)
            for v in out_neighbors(residual_graph, u)
                if capacity_matrix[u, v] - flow_matrix[u, v] > 0 && P[v] == -1
                    P[v] = u
                    if S[v] == -1
                        unshift!(Q_f, v)
                    else
                        return v, P, S, 0 # 0 indicates success
                    end
                end
            end

            length(Q_f) == 0 && return 0, P, S, 1 # No paths to target
        else
            v = pop!(Q_r)
            for u in in_neighbors(residual_graph, v)
                if capacity_matrix[u, v] - flow_matrix[u, v] > 0 && S[u] == -1
                    S[u] = v
                    P[u] != -1 && return u, P, S, 0 # 0 indicates success

                    unshift!(Q_r, u)
                end

            end

            length(Q_r) == 0 && return 0, P, S, 2 # No paths to source
        end
    end
end


"""
    fetch_path(residual_graph, source, target, flow_matrix, capacity_matrix)


Use bidirectional BFS to look for augmentable paths from `source` to `target` in
`residual_graph`. Return the vertex where the two BFS searches intersect,
the parent table of the path, the successor table of the path found, and a
flag indicating success (0 => success; 1 => no path to target, 2 => no path
to source).
"""
function fetch_path end
@traitfn function fetch_path(
    residual_graph::::IsDirected,               # the input graph
    source::Integer,                           # the source vertex
    target::Integer,                           # the target vertex
    flow_matrix::AbstractMatrix,       # the current flow matrix
    capacity_matrix::AbstractMatrix    # edge flow capacities
    )
    n = nv(residual_graph)
    P = fill(-1, n)
    S = fill(-1, n)
    return fetch_path!(residual_graph,
    source,
    target,
    flow_matrix,
    capacity_matrix,
    P,
    S)
end
