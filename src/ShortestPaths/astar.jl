# Parts of this file were taken from / inspired by OpenStreetMapX.jl. See LICENSE.md for details.
# A* shortest-path algorithm
"""
    struct AStar <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [A* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm).
An optional `heuristic` function may be supplied. If missing, the heuristic is set to
`n -> 0`.

### Implementation Notes
`AStar` supports the following shortest-path functionality:
- non-negative distance matrices / weights
- single destination
"""
struct AStar{F<:Function} <: ShortestPathAlgorithm
    heuristic::F
end

AStar(T::Type=Float64) = AStar((u, v) -> zero(T))

struct AStarResult{T, U<:Integer} <: ShortestPathResult
    path::Vector{U}
    dist::T
end

function ==(a::ShortestPaths.AStarResult, b::ShortestPaths.AStarResult)
   return a.path == b.path && a.dist == b.dist
end

parents(::AStarResult) = throw(LightGraphs.NotImplementedError("parents"))

function reconstruct_path(parents::Vector{T},s::Integer, u::Integer) where {T<:Integer}
    route = Vector{T}()
    index = u
    push!(route, index)
    while index != s
        index = parents[index]
        push!(route, index)
    end
    return reverse(route)
end

function shortest_paths(g::AbstractGraph{U}, s::Integer, t::Integer, distmx::AbstractMatrix{T}, alg::AStar) where {U<:Integer, T<:Real}
    checkbounds(distmx, Base.OneTo(nv(g)), Base.OneTo(nv(g)))
    frontier = PriorityQueue{Tuple{T, U}, T}()
    frontier[(zero(T), U(s))] = zero(T)
    nvg = nv(g)
    visited = falses(nvg)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    colormap = zeros(UInt8, nvg)
    colormap[s] = 1
    @inbounds while !isempty(frontier)
        (cost_so_far, u) = dequeue!(frontier)
        u == t && return AStarResult(reconstruct_path(parents, s, u), cost_so_far)
        for v in LightGraphs.outneighbors(g, u)
            if colormap[v] < 2
                dist = distmx[u, v]
                colormap[v] = 1
                path_cost = cost_so_far + dist
                if !visited[v] 
                    visited[v] = true
                    parents[v] = u
                    dists[v] = path_cost
                    enqueue!(frontier, (path_cost, v), path_cost + alg.heuristic(v, t))
                elseif path_cost < dists[v]
                    parents[v] = u
                    dists[v] = path_cost
                    frontier[path_cost, v] = path_cost + alg.heuristic(v, t)
                end
            end
        end
        colormap[u] = 2
    end
    return AStarResult(Vector{U}(), typemax(T))
end


shortest_paths(g::AbstractGraph, s::Integer, t::Integer, alg::AStar) = shortest_paths(g, s, t, weights(g), alg)
paths(s::AStarResult) = [s.path]
paths(s::AStarResult, v::Integer) = throw(ArgumentError("AStar produces at most one path."))
dists(s::AStarResult) = [[s.dist]]
dists(s::AStarResult, v::Integer) = throw(ArgumentError("AStar produces at most one path."))

