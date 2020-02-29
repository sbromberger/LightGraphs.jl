function extract_a_star_route(parents::Vector{T},s::Integer, u::Integer) where {T<:Integer}
    route = Vector{T}()
    index = u
    push!(route,index)
    while index != s
        index = parents[index]
        push!(route, index)
    end
    return reverse(route)
end

struct AStar2{F<:Function} <: ShortestPathAlgorithm
    heuristic::F
end

AStar2(T::Type=Float64) = AStar2((u,v) -> zero(T))

const AStar2Result = AStarResult

"""
    a_star_algorithm(g::AbstractGraph{U},  
                    s::Integer,                       
                    t::Integer,                       
                    distmx::AbstractMatrix{T}=LightGraphs.weights(g),
                    heuristic::Function = (u,v) -> zero(T)) where {T, U}

High level function - implementation of A star search algorithm:
(https://en.wikipedia.org/wiki/A*_search_algorithm). 
Based on the implementation in LightGraphs library, 
however significantly improved in terms of performance.

**Arguments**

* `g` : graph object
* `S` : start vertex
* `t` : end vertex
* `distmx` : distance matrix
* `heuristic` : search heuristic function; by default returns zero 
"""
function shortest_paths(g::AbstractGraph{U}, s::Integer, t::Integer, distmx::AbstractMatrix{T}, alg::AStar2) where {U<:Integer, T<:Real}
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
        u == t && return AStarResult(extract_a_star_route(parents, s, u), cost_so_far)
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
    Vector{U}(), Inf
end

shortest_paths(g::AbstractGraph, s::Integer, t::Integer, a::AStar2) = shortest_paths(g, s, t, weights(g), a)
