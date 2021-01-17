# Bidirectional A* shortest-path search
# See Goldberg et al: https://archive.siam.org/meetings/alenex05/papers/03agoldberg.pdf
# For v1, use alternating strategy between forward and backward search
# TODO: Eventually make alternating strategy an argument in BidirAStar
struct BidirAStar{F1<:Function, F2<:Function} <: ShortestPathAlgorithm
    fwd_heuristic::F1
    bwd_heuristic::F2
end

BidirAStar(T::Type=Float64) = BidirAStar((u, v) -> zero(T), (u, v) -> zero(T))

function reconstruct_path(fwd_parents::Vector{T}, bwd_parents::Vector{T}, u::Integer, s::Integer, t::Integer) where {T<:Integer}
    # Use fwd_parents from s to u and bwd_parents from t to u
    route = Vector{T}()
    # First push path to u
    index = u
    push!(route, index)
    while index != s
        index = fwd_parents[index]
        push!(route, index)
    end
    reverse!(route)

    # Only continue if u is not t
    if u != t
        index = bwd_parents[u]
        push!(route, index)
        while index != t
            index = bwd_parents[index]
            push!(route, index)
        end
    end
    return route
end

function shortest_paths(g::AbstractGraph{U}, s::Integer, t::Integer, distmx::AbstractMatrix{T}, alg::BidirAStar) where {U<:Integer, T<:Real}
    checkbounds(distmx, Base.OneTo(nv(g)), Base.OneTo(nv(g)))
    
    # TODO: Do we need this check?
    @assert s != t "Source and Target must be different!"

    nvg = nv(g)
    search_bit = 0  # Search fwd when 0, bwd when 1. Flip each time
    best_path_cost = typemax(T) # The mu variable from reference paper
    best_path = Vector{U}()

    # Need two copies of bookkeeping for fwd and bwd search
    fwd_frontier = PriorityQueue{Tuple{T, U}, T}()
    fwd_frontier[(zero(T), U(s))] = zero(T)
    fwd_visited = falses(nvg)
    fwd_visited[s] = true
    fwd_dists = fill(typemax(T), nvg)
    fwd_dists[s] = zero(T)
    fwd_parents = zeros(U, nvg)
    fwd_colormap = zeros(UInt8, nvg)
    fwd_colormap[s] = 1

    bwd_frontier = PriorityQueue{Tuple{T, U}, T}()
    bwd_frontier[(zero(T), U(t))] = zero(T)
    bwd_visited = falses(nvg)
    bwd_visited[t] = true
    bwd_dists = fill(typemax(T), nvg)
    bwd_dists[t] = zero(T)
    bwd_parents = zeros(U, nvg)
    bwd_colormap = zeros(UInt8, nvg)
    bwd_colormap[t] = 1

    # TODO (v2): There should be a more code-efficient way to alternate the searches
    # where the outneighbors or inneighbors are called and the corresponding bookkeeping is used
    @inbounds while !isempty(fwd_frontier) || !isempty(bwd_frontier)
        # Forward or backward search based on bit
        # Terminate when expanded vertex has been scanned by other search
        if search_bit == 0 && !isempty(fwd_frontier)
            (cost_so_far, u) = dequeue!(fwd_frontier)

            cost_so_far + alg.fwd_heuristic(u, t) > best_path_cost && return AStarResult(best_path, best_path_cost)
            
            for v in LightGraphs.outneighbors(g, u)
                if fwd_colormap[v] < 2
                    dist = distmx[u, v]
                    fwd_colormap[v] = 1
                    path_cost = cost_so_far + dist
                    
                    if !fwd_visited[v]
                        fwd_visited[v] = true
                        fwd_parents[v] = u
                        fwd_dists[v] = path_cost
                        enqueue!(fwd_frontier, (path_cost, v), path_cost + alg.fwd_heuristic(v, t))
                    elseif path_cost < fwd_dists[v]
                        # See pruning (Sec 6.4) from ref paper: only update fwd_frontier
                        # IF optimistic path through u -> v can improve on best
                        if path_cost + alg.fwd_heuristic(v, t) < best_path_cost
                            fwd_parents[v] = u
                            fwd_dists[v] = path_cost
                            fwd_frontier[path_cost, v] = path_cost + alg.fwd_heuristic(v, t)
                        end
                    end     
                    # If v scanned by bwd search and path through u->v is better than best, update
                    if bwd_colormap[v] == 2 && fwd_dists[v] + bwd_dists[v] < best_path_cost
                        best_path_cost = fwd_dists[v] + bwd_dists[v]
                        best_path = reconstruct_path(fwd_parents, bwd_parents, v, s, t)
                    end
                end # fwd_colormap[v] < 2
            end # v in outneighbors
            fwd_colormap[u] = 2
        elseif search_bit == 1 && !isempty(bwd_frontier)
            (cost_so_far, u) = dequeue!(bwd_frontier)
            
            cost_so_far + alg.bwd_heuristic(u, s) > best_path_cost && return AStarResult(best_path, best_path_cost)
            
            for v in LightGraphs.inneighbors(g, u)
                if bwd_colormap[v] < 2
                    dist = distmx[v, u]
                    bwd_colormap[v] = 1
                    path_cost = cost_so_far + dist

                    if !bwd_visited[v]
                        bwd_visited[v] = true
                        bwd_parents[v] = u
                        bwd_dists[v] = path_cost
                        enqueue!(bwd_frontier, (path_cost, v), path_cost + alg.bwd_heuristic(v, s))
                    elseif path_cost < bwd_dists[v]
                        # Prune again
                        if path_cost + alg.bwd_heuristic(v, s) < best_path_cost
                            bwd_parents[v] = u
                            bwd_dists[v] = path_cost
                            bwd_frontier[path_cost, v] = path_cost + alg.bwd_heuristic(v, s)
                        end
                    end
                    if fwd_colormap[v] == 2 && fwd_dists[v] + bwd_dists[v] < best_path_cost
                        best_path_cost = fwd_dists[v] + bwd_dists[v]
                        best_path = reconstruct_path(fwd_parents, bwd_parents, v, s, t)
                    end
                end # bwd_colormap[v] < 2
            end # v in inneighbors
            bwd_colormap[u] = 2
        end # if search_bit

        # Flip the search bit
        search_bit = (search_bit + 1)%2
    end # while !empty
    return AStarResult(Vector{U}(), typemax(T))
end # end function shortest_paths

shortest_paths(g::AbstractGraph, s::Integer, t::Integer, alg::BidirAStar) = shortest_paths(g, s, t, weights(g), alg)
