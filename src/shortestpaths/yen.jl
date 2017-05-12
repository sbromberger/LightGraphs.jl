"""
    struct YenState{T, U}
Designed for yen k-shortest-paths calculations.
"""
struct YenState{T, U<:Integer}<: AbstractPathState
    dists::Vector{T}
    paths::Vector{Vector{U}}
end


"""
  yen_k_shortest_paths(g, source, target, distmx=DefaultDistance(), K);

  Perform [Yen's algorithm](http://en.wikipedia.org/wiki/Yen%27s_algorithm)
  on a graph, computing k-shortest distances between `source` and `target` other vertices.
  Return a [`YenState`](@ref) that contains distances and paths.

  ### Optional Arguments
  - `k=1`: The number of paths to find.

"""
function yen_k_shortest_paths(
    g::AbstractGraph,
    source::U,
    target::U,
    distmx::AbstractMatrix{T}=DefaultDistance(),
    K::Int=1) where T where U<:Integer

    if source == target
        return YenState{T, U}([U(0)], [[source]])
    end

    dj = dijkstra_shortest_paths(g, source, distmx)
    path = enumerate_paths(dj)[target]
    if isempty(path)
        return YenState{T, U}(Vector{T}(), Vector{Vector{U}}())
    end

    dists = Array{T,1}()
    push!(dists,dj.dists[target])
    A = [path]
    B = PriorityQueue()
    gcopy = deepcopy(g)

    for k = 1:(K-1)
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
                        push!(edgesremoved,(u, v))
                    end
                end
            end

            # Remove node of root path
            for n = 1:(length(rootpath)-1)
                u = rootpath[n]
                nei = copy(neighbors(gcopy,u))
                for v in nei
                    rem_edge!(gcopy, u, v)
                    push!(edgesremoved,(u, v))
                end
            end

            # Calculate the spur path from the spur node to the sink
            djspur = dijkstra_shortest_paths(gcopy, spurnode, distmx)
            spurpath = enumerate_paths(djspur)[target]
            if !isempty(spurpath)
                # Entire path is made up of the root path and spur path
                pathtotal = [rootpath[1:end-1];spurpath]
                distpath  = dj.dists[spurnode] + djspur.dists[target]
                # Add the potential k-shortest path to the heap
                if !haskey(B,pathtotal)
                    enqueue!(B, pathtotal, distpath)
                end
            end

            for (u, v) in edgesremoved
                add_edge!(gcopy, u, v)
            end
        end
        if !isempty(B)
            push!(dists,DataStructures.peek(B)[2])
            push!(A,dequeue!(B))
        else
            break
        end
    end

    return YenState{T, U}(dists, A)
end
