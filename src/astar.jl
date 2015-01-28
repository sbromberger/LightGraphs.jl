# A* shortest-path algorithm
module AStar

# The enqueue! and dequeue! methods defined in Base.Collections (needed for
# PriorityQueues) conflict with those used for queues. Hence we wrap the A*
# code in its own module.

using LightGraphs
using Base.Collections

export a_star

function a_star_impl!(
    graph::AbstractGraph,# the graph
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{Int},  # an (initialized) color-map to indicate status of vertices
    edge_dists::AbstractArray{Float64, 2},
    heuristic::Function,    # heuristic fn (under)estimating distance to target
    t::Int)  # the end vertex

    use_dists = issparse(edge_dists)? nnz(edge_dists > 0) : !isempty(edge_dists)

    while !isempty(frontier)
        (cost_so_far, path, u) = dequeue!(frontier)
        if u == t
            return path
        end

        for edge in out_edges(graph, u)

            v = edge.dst
            if colormap[v] < 2
                if use_dists
                    edist = edge_dists[src(edge), dst(edge)]
                    if edist == 0.0
                        edist = 1.0
                    end
                else
                    edist = 1.0
                end
                colormap[v] = 1
                new_path = cat(1, path, edge)
                path_cost = cost_so_far + edist
                enqueue!(frontier,
                        (path_cost, new_path, v),
                        path_cost + heuristic(v))
            end
        end
        colormap[u] = 2
    end
    nothing
end


function a_star(
    graph::AbstractGraph,  # the graph
    edge_dists::AbstractArray{Float64, 2},
    s::Int,                       # the start vertex
    t::Int,                       # the end vertex
    heuristic::Function = n -> 0
    )
            # heuristic (under)estimating distance to target
    frontier = VERSION < v"0.4-" ? PriorityQueue{(Float64,Array{Edge,1},Int),Float64}() : PriorityQueue((Float64,Array{Edge,1},Int),Float64)
    frontier[(zero(Float64), Edge[], s)] = zero(Float64)
    colormap = zeros(Int, nv(graph))
    colormap[s] = 1
    a_star_impl!(graph, frontier, colormap, edge_dists, heuristic, t)
end

# function a_star(
#     graph::AbstractGraph,  # the graph
#     s::Int,                       # the start vertex
#     t::Int,                       # the end vertex
#     heuristic::Function = n -> 0
#     )
#     a_star(graph, Array(Float64,(0,0)), s, t, heuristic)
# end

a_star(
    graph::AbstractGraph,
    s::Int, t::Int;
    heuristic::Function = n->0,
    edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))
) = a_star(graph, edge_dists, s, t, heuristic)

end

using .AStar
