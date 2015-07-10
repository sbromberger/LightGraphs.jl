# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# A* shortest-path algorithm

function a_star_impl!{T<:Number}(
    graph::SimpleGraph,# the graph
    t::Int, # the end vertex
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{Int},  # an (initialized) color-map to indicate status of vertices
    distmx::AbstractArray{T, 2},
    heuristic::Function    # heuristic fn (under)estimating distance to target
    )

    while !isempty(frontier)
        (cost_so_far, path, u) = dequeue!(frontier)
        if u == t
            return path
        end

        for v in LightGraphs.fadj(graph, u)

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


function a_star{T<:Number}(
    graph::SimpleGraph,  # the graph

    s::Int,                       # the start vertex
    t::Int,                       # the end vertex
    distmx::AbstractArray{T, 2} = LightGraphs.DefaultDistance(),
    heuristic::Function = n -> 0
    )
            # heuristic (under)estimating distance to target
    frontier = VERSION < v"0.4-" ?
        PriorityQueue{@compat(Tuple{T,Array{Edge,1},Int}),T}() :
        PriorityQueue(@compat(Tuple{T,Array{Edge,1},Int}),T)
    frontier[(zero(T), Edge[], s)] = zero(T)
    colormap = zeros(Int, nv(graph))
    colormap[s] = 1
    a_star_impl!(graph, t, frontier, colormap, distmx, heuristic)
end
