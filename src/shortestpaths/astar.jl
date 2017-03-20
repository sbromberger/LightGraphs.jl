# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# A* shortest-path algorithm

function a_star_impl!(
    graph::AbstractGraph,# the graph
    t::Integer, # the end vertex
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{Int},  # an (initialized) color-map to indicate status of vertices
    distmx::AbstractMatrix,
    heuristic::Function    # heuristic fn (under)estimating distance to target
    )

    while !isempty(frontier)
        (cost_so_far, path, u) = dequeue!(frontier)
        if u == t
            return path
        end

        for v in LightGraphs.out_neighbors(graph, u)

            if colormap[v] < 2
                dist = distmx[u, v]

                colormap[v] = 1
                new_path = cat(1, path, Edge(u,v))
                path_cost = cost_so_far + dist
                enqueue!(frontier,
                (path_cost, new_path, v),
                path_cost + heuristic(v))
            end
        end
        colormap[u] = 2
    end
    nothing
end

"""
Computes the shortest path between vertices `s` and `t` using the
[A\* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm). An
optional heuristic function and edge distance matrix may be supplied.
"""
function a_star(
    graph::AbstractGraph,  # the graph

    s::Integer,                       # the start vertex
    t::Integer,                       # the end vertex
    distmx::AbstractMatrix{T} = LightGraphs.DefaultDistance(),
    heuristic::Function = n -> 0
    ) where T
    # heuristic (under)estimating distance to target
    U = eltype(graph)
    frontier = PriorityQueue(Tuple{T,Vector{Edge},U},T)
    frontier[(zero(T), Vector{Edge}(), s)] = zero(T)
    colormap = zeros(Int, nv(graph))
    colormap[s] = 1
    a_star_impl!(graph, t, frontier, colormap, distmx, heuristic)
end
