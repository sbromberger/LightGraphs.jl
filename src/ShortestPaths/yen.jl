"""
    struct Yen <: ShortestPathAlgorithm
        k::Int
    end

The structure used to configure and specify that [`shortest_paths`](@ref)
should use [Yen's algorithm](https://en.wikipedia.org/wiki/Yen%27s_algorithm)
to compute shortest paths. Optional fields for this structure include

- `k::Int`: Specify that the algorithm should find the `k` shortest paths (default: `1`).
- `maxdist::Float64`: Specifies the maximum distance to traverse before exiting (default: `Inf`)
"""
struct Yen <: ShortestPathAlgorithm
    k::Int
    maxdist::Float64
end

Yen(;k=1, maxdist=Inf) = Yen(1, maxdist)

"""
    struct YenResult{T, U}

Designed for yen k-shortest-paths calculations.
"""
struct YenResult{T,U <: Integer} <: ShortestPathResult
    dists::Vector{T}
    paths::Vector{Vector{U}}
end


function shortest_paths(g::AbstractGraph, source::U, target::U, distmx::AbstractMatrix{T}, alg::Yen) where {T<:Real, U <: Integer}

    source == target && return YenResult{T,U}([U(0)], [[source]])

    dalg = LightGraphs.Experimental.ShortestPaths.Dijkstra(maxdist=alg.maxdist)
    dj = LightGraphs.Experimental.ShortestPaths.shortest_paths(g, source, distmx, dalg)

    path = LightGraphs.Experimental.ShortestPaths.paths(dj, target)
    isempty(path) && return YenResult{T,U}(Vector{T}(), Vector{Vector{U}}())

    dists = Array{T,1}()
    push!(dists, dj.dists[target])
    A = [path]
    B = PriorityQueue()
    gcopy = deepcopy(g)

    for k = 1:(alg.k - 1)
        for j = 1:length(A[k])
            # Spur node is retrieved from the previous k-shortest path, k − 1
            spurnode = A[k][j]
            #  The sequence of nodes from the source to the spur node of the previous k-shortest path
            rootpath = A[k][1:j]

            # Store the removed edges
            edgesremoved = Array{Tuple{Int,Int},1}()
            # Remove the links of the previous shortest paths which share the same root path
            for ppath in A
                if length(ppath) > j && rootpath == ppath[1:j]
                    u = ppath[j]
                    v = ppath[j + 1]
                    if has_edge(gcopy, u, v)
                        rem_edge!(gcopy, u, v)
                        push!(edgesremoved, (u, v))
                    end
                end
            end

            # Remove node of root path and calculate dist of it
            distrootpath = 0.
            for n = 1:(length(rootpath) - 1)
                u = rootpath[n]
                nei = copy(neighbors(gcopy, u))
                for v in nei
                    rem_edge!(gcopy, u, v)
                    push!(edgesremoved, (u, v))
                end

                # Evaluate distante of root path
                v = rootpath[n + 1]
                distrootpath += distmx[u, v]
            end

            # Calculate the spur path from the spur node to the sink
            djspur = shortest_paths(gcopy, spurnode, distmx, Dijkstra())
            spurpath = paths(djspur)[target]
            if !isempty(spurpath)
                # Entire path is made up of the root path and spur path
                pathtotal = [rootpath[1:(end - 1)]; spurpath]
                distpath  = distrootpath + djspur.dists[target]
                # Add the potential k-shortest path to the heap
                if !haskey(B, pathtotal)
                    enqueue!(B, pathtotal, distpath)
                end
            end

            for (u, v) in edgesremoved
                add_edge!(gcopy, u, v)
            end
        end

        # No more paths in B
        isempty(B) && break
        mindistB = peek(B)[2]
        # The path with minimum distance in B is higher than maxdist
        mindistB > maxdist && break
        push!(dists, peek(B)[2])
        push!(A, dequeue!(B))
    end

    return YenResult{T,U}(dists, A)
end
