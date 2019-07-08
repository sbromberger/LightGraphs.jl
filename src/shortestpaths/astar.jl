# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# A* shortest-path algorithm

function reconstruct_path!(total_path, # a vector to be filled with the shortest path
    came_from, # a vector holding the parent of each node in the A* exploration
    end_idx, # the end vertex
    g) # the graph

    E = Edge{eltype(g)}
    curr_idx = end_idx
    while came_from[curr_idx] != curr_idx
        pushfirst!(total_path, E(came_from[curr_idx], curr_idx))
        curr_idx = came_from[curr_idx]
    end
end

function a_star_impl!(g, # the graph
    goal, # the end vertex
    open_set, # an initialized heap containing the active vertices
    closed_set, # an (initialized) color-map to indicate status of vertices
    g_score, # a vector holding g scores for each node
    f_score, # a vector holding f scores for each node
    came_from, # a vector holding the parent of each node in the A* exploration
    distmx,
    heuristic)

    E = Edge{eltype(g)}
    total_path = Vector{E}()

    @inbounds while !isempty(open_set)
        current = dequeue!(open_set)

        if current == goal
            reconstruct_path!(total_path, came_from, current, g)
            return total_path
        end

        closed_set[current] = true

        for neighbor in LightGraphs.outneighbors(g, current)
            if closed_set[neighbor]
                continue
            end

            tentative_g_score = g_score[current] + distmx[current, neighbor]

            if tentative_g_score < g_score[neighbor]
                g_score[neighbor] = tentative_g_score
                priority = tentative_g_score + heuristic(neighbor)
                enqueue!(open_set, neighbor, priority)
                came_from[neighbor] = current
            end
        end
    end
    return total_path
end

"""
    a_star(g, s, t[, distmx][, heuristic])

Return a vector of edges comprising the shortest path between vertices `s` and `t`
using the [A* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm).
An optional heuristic function and edge distance matrix may be supplied. If missing,
the distance matrix is set to [`LightGraphs.DefaultDistance`](@ref) and the heuristic is set to
`n -> 0`.
"""
function a_star(g::AbstractGraph{U},  # the g
    s::Integer,                       # the start vertex
    t::Integer,                       # the end vertex
    distmx::AbstractMatrix{T}=weights(g),
    heuristic::Function=n -> zero(T)) where {T, U}

    E = Edge{eltype(g)}

    # if we do checkbounds here, we can use @inbounds in a_star_impl!
    checkbounds(distmx, Base.OneTo(nv(g)), Base.OneTo(nv(g)))

    open_set = PriorityQueue{Integer, T}()
    enqueue!(open_set, s, 0)

    closed_set = zeros(Bool, nv(g))

    g_score = ones(T, nv(g)) * Inf # Type of Inf? T(Inf)? Harms integers...
    g_score[s] = 0

    f_score = ones(T, nv(g)) * Inf # Type of Inf? T(Inf)? Harms integers...
    f_score[s] = heuristic(s) # Type of s? U(s)? We don't know the form of heuristic

    came_from = -ones(Integer, nv(g))
    came_from[s] = s

    a_star_impl!(g, t, open_set, closed_set, g_score, f_score, came_from, distmx, heuristic)
end
