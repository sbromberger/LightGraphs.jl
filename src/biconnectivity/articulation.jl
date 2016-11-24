id = 0

"""
Computes the articulation points(https://en.wikipedia.org/wiki/Biconnected_component)
of a connected graph `g` and returns an array containing all cut vertices.
"""

function articulation(g::SimpleGraph) :: AbstractArray{Int}
    depth = zeros(Int, nv(g))
    low = zeros(Int, nv(g))
    articulation_points = fill(false, nv(g))

    for u in 1:nv(g)
        depth[u] == 0 && visit!(g, depth, low, articulation_points, u, u)
    end
    return [x for (x, y) in enumerate(articulation_points) if y == true]
end

"""
Does a depth first search storing the depth (in `depth`) and low-points (in `low`) of each vertex.
"""
function visit!(g::SimpleGraph, depth::AbstractArray{Int},
                low::AbstractArray{Int}, articulation_points::AbstractArray{Bool},
                u::Int, v::Int)
    children = 0
    global id
    id = id + 1
    depth[v] = id
    low[v] = depth[v]

    for w in fadj(g)[v]
        if depth[w] == 0
            children = children + 1
            visit!(g, depth, low, articulation_points, v, w)

            low[v] = min(low[v], low[w])
            if low[w] >= depth[v] && u != v
                articulation_points[v] = true
            end

        elseif w != u
            low[v] = min(low[v], depth[w])
        end
	end

    if u == v && children > 1
        articulation_points[v] = true
    end
end