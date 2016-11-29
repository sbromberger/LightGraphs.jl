type Articulations
    low::Vector{Int}
    depth::Vector{Int}
    articulation_points::Vector{Bool}
    id::Int
end

function new_articulations(n::Int)
    return Articulations(zeros(Int, n), zeros(Int, n), zeros(Int, n), 0)
end

"""
Computes the articulation points(https://en.wikipedia.org/wiki/Biconnected_component)
of a connected graph `g` and returns an array containing all cut vertices.
"""

function articulation(g::SimpleGraph) :: AbstractArray{Int}
    state = new_articulations(nv(g))
    for u in vertices(g)
        state.depth[u] == 0 && visit!(g, state, u, u)
    end
    return [x for (x, y) in enumerate(state.articulation_points) if y == true]
end

"""
Does a depth first search storing the depth (in `depth`) and low-points (in `low`) of each vertex.
"""
function visit!(g::SimpleGraph, state::Articulations, u::Int, v::Int)
    children = 0
    state.id += 1
    state.depth[v] = state.id
    state.low[v] = state.depth[v]

    for w in out_neighbors(g, v)
        if state.depth[w] == 0
            children = children + 1
            visit!(g, state, v, w)

            state.low[v] = min(state.low[v], state.low[w])
            if state.low[w] >= state.depth[v] && u != v
                state.articulation_points[v] = true
            end

        elseif w != u
            state.low[v] = min(state.low[v], state.depth[w])
        end
	end

    if u == v && children > 1
        state.articulation_points[v] = true
    end
end
