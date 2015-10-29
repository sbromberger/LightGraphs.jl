"""push_relabel
Implementation of the FIFO push relabel algorithm with gap heuristic. Takes
approximately O(V^3) time.

Maintains the following auxillary arrays:
height -> Stores the labels of all vertices
count  -> Stores the number of vertices at each height
excess -> Stores the difference between incoming and outgoing flow for all vertices
active -> Stores the status of all vertices. (e(v)>0 => active[v] = true)
Q      -> The FIFO queue that stores active vertices waiting to be discharged.

Requires arguments:
flow_graph::LightGraphs.DiGraph        # the input graph
source::Int                            # the source vertex
target::Int                            # the target vertex
capacity_matrix::AbstractArray{T,2}    # edge flow capacities
"""

function push_relabel{T<:Number}(
    flow_graph::LightGraphs.DiGraph,       # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2}=   # edge flow capacities
        DefaultDistance()
    )

    n = nv(flow_graph)

    flow_matrix = zeros(T, n, n)

    height = zeros(Int, n)
    height[source] = n

    count = zeros(Int, 2*n+1)
    count[0+1] = n-1
    count[n+1] = 1

    excess = zeros(T, n)
    excess[source] = typemax(T)

    active = falses(n)
    active[source] = true
    active[target] = true

    Q = Array{Int,1}()
    sizehint!(Q, n)


    for v in fadj(flow_graph, source)
        push_flow!(flow_graph, source, v, capacity_matrix, flow_matrix, excess, height, active, Q)
    end

    while length(Q) > 0
        v = pop!(Q)
        active[v] = false
        discharge!(flow_graph, v, capacity_matrix, flow_matrix, excess, height, active, count, Q)
    end

    return sum([flow_matrix[v,target] for v in badj(flow_graph, target) ]), flow_matrix
end

"""enqueue_vertex!
Pushes inactive nodes into the queue and activates them.

Requires arguments:
Q::AbstractArray{Int,1}
v::Int                                 # input vertex
active::AbstractArray{Bool,1}
excess::AbstractArray{T,1}
"""

function enqueue_vertex!{T<:Number}(
    Q::AbstractArray{Int,1},
    v::Int,                                # input vertex
    active::AbstractArray{Bool,1},
    excess::AbstractArray{T,1}
    )
    if !active[v] && excess[v] > 0
        active[v] = true
        unshift!(Q, v)
    end
    nothing
end

"""push_flow!
Pushes as much flow as possible through the given edge.

Requires arguements:
flow_graph::LightGraphs.DiGraph      # the input graph
u::Int                               # input from-vertex
v::Int                               # input to-vetex
capacity_matrix::AbstractArray{T,2}
flow_matrix::AbstractArray{T,2}
excess::AbstractArray{T,1}
height::AbstractArray{Int,1}
active::AbstractArray{Bool,1}
Q::AbstractArray{Int,1}
"""

function push_flow!{T<:Number}(
    flow_graph::LightGraphs.DiGraph,     # the input graph
    u::Int,                              # input from-vertex
    v::Int,                              # input to-vetex
    capacity_matrix::AbstractArray{T,2},
    flow_matrix::AbstractArray{T,2},
    excess::AbstractArray{T,1},
    height::AbstractArray{Int,1},
    active::AbstractArray{Bool,1},
    Q::AbstractArray{Int,1}
    )
    flow = min(excess[u], capacity_matrix[u,v] - flow_matrix[u,v])

    flow == 0 && return nothing
    height[u] <= height[v] && return nothing

    flow_matrix[u,v] += flow
    flow_matrix[v,u] -= flow

    excess[u] -= flow
    excess[v] += flow

    enqueue_vertex!(Q, v, active, excess)
    nothing
end

  """gap!
  Implements the gap heuristic. Relabels all vertices above a cutoff height.
  Reduces the number of relabels required.

  Requires arguments:
  flow_graph::LightGraphs.DiGraph        # the input graph
  h::Int                                 # cutoff height
  excess::AbstractArray{T,1}
  height::AbstractArray{Int,1}
  active::AbstractArray{Bool,1}
  count::AbstractArray{Int,1}
  Q::AbstractArray{Int,1}                # FIFO queue
  """

function gap!{T<:Number}(
    flow_graph::LightGraphs.DiGraph,       # the input graph
    h::Int,                                # cutoff height
    excess::AbstractArray{T,1},
    height::AbstractArray{Int,1},
    active::AbstractArray{Bool,1},
    count::AbstractArray{Int,1},
    Q::AbstractArray{Int,1}                # FIFO queue
    )
    n = nv(flow_graph)
    for v in vertices(flow_graph)
        height[v] < h && continue
        count[height[v]+1] -= 1
        height[v] = max(height[v], n + 1)
        count[height[v]+1] += 1
        enqueue_vertex!(Q, v, active, excess)
    end
end

"""relabel!
Relabels a vertex with respect to its neighbors, to produce an admissable
edge.

Requires arguments:
flow_graph::LightGraphs.DiGraph         # the input graph
v::Int                                  # input vertex to be relabeled
capacity_matrix::AbstractArray{T,2}
flow_matrix::AbstractArray{T,2}
excess::AbstractArray{T,1}
height::AbstractArray{Int,1}
active::AbstractArray{Bool,1}
count::AbstractArray{Int,1}
Q::AbstractArray{Int,1}
"""

function relabel!{T<:Number}(
    flow_graph::LightGraphs.DiGraph,        # the input graph
    v::Int,                                 # input vertex to be relabeled
    capacity_matrix::AbstractArray{T,2},
    flow_matrix::AbstractArray{T,2},
    excess::AbstractArray{T,1},
    height::AbstractArray{Int,1},
    active::AbstractArray{Bool,1},
    count::AbstractArray{Int,1},
    Q::AbstractArray{Int,1}
    )
    n = nv(flow_graph)
    count[height[v]+1] -= 1
    height[v] = 2*n
    for to in fadj(flow_graph, v)
        if capacity_matrix[v,to] > flow_matrix[v,to]
            height[v] = min(height[v], height[to]+1)
        end
    end
    count[height[v]] += 1
    enqueue_vertex!(Q, v, active, excess)
    nothing
end


"""discharge!
Drains the excess flow out of a vertex. Run's the gap heuristic or relabels the
vertex if the excess remains non-zero.

Requires arguments:
flow_graph::LightGraphs.DiGraph         # the input graph
v::Int                                  # vertex to be discharged
capacity_matrix::AbstractArray{T,2}
flow_matrix::AbstractArray{T,2}
excess::AbstractArray{T,1}
height::AbstractArray{Int,1}
active::AbstractArray{Bool,1}
count::AbstractArray{Int,1}
Q::AbstractArray{Int,1}                 # FIFO queue
"""
function discharge!{T<:Number}(
    flow_graph::LightGraphs.DiGraph,        # the input graph
    v::Int,                                 # vertex to be discharged
    capacity_matrix::AbstractArray{T,2},
    flow_matrix::AbstractArray{T,2},
    excess::AbstractArray{T,1},
    height::AbstractArray{Int,1},
    active::AbstractArray{Bool,1},
    count::AbstractArray{Int,1},
    Q::AbstractArray{Int,1}                 # FIFO queue
    )
    for to in fadj(flow_graph, v)
        excess[v] == 0 && break
        push_flow!(flow_graph, v, to, capacity_matrix, flow_matrix, excess, height, active, Q)
    end

    if excess[v] > 0
        if count[height[v]+1] == 1
            gap!(flow_graph, height[v], excess, height, active, count, Q)
        else
            relabel!(flow_graph, v, capacity_matrix, flow_matrix, excess, height, active, count, Q)
        end
    end
    nothing
end
