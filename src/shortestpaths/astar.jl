# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# A* shortest-path algorithm

function a_star_impl!(g::AbstractGraph,# the graph
    t, # the end vertex
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{UInt8},  # an (initialized) color-map to indicate status of vertices
    distmx::AbstractMatrix,
    heuristic::Function)

    E = Edge{eltype(g)}

    @inbounds while !isempty(frontier)
        (cost_so_far, path, u) = dequeue!(frontier)
        if u == t
            return path
        end

        for v in LightGraphs.outneighbors(g, u)

            if get(colormap, v, 0) < 2
                dist = distmx[u, v]
                colormap[v] = 1
                new_path = cat(path, E(u, v), dims=1)
                path_cost = cost_so_far + dist
                enqueue!(frontier,
                    (path_cost, new_path, v),
                    path_cost + heuristic(v)
                )
            end
        end
        colormap[u] = 2
    end
    Vector{E}()
end

"""
    empty_colormap(nv)

Return a collection that maps vertices of type `typof(nv)` to UInt8.
In case `nv` is an integer type, this will be a vector of zeros. Currently does
not work for other types. The idea is, that this can be extended to arbitrary
vertex types in the future.
"""
empty_colormap(nv::Integer) = zeros(UInt8, nv)

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
    # heuristic (under)estimating distance to target
    frontier = PriorityQueue{Tuple{T,Vector{E},U},T}()
    frontier[(zero(T), Vector{E}(), U(s))] = zero(T)
    colormap = empty_colormap(nv(g))
    colormap[s] = 1
    a_star_impl!(g, U(t), frontier, colormap, distmx, heuristic)
end
