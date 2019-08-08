struct DijkstraResults{T<:Real, U<:Integer}  <: ShortestPathResults
    parents::Vector{U}
    dists::Vector{T}
    predecessors::Vector{Vector{U}}
    pathcounts::Vector{UInt64}
    closest_vertices::Vector{U}
end

struct Dijkstra <: ShortestPathAlgorithm
    all_paths::Bool
    track_vertices::Bool
end

Dijkstra(;all_paths=false, track_vertices=false) = Dijkstra(all_paths, track_vertices)


"""
    dijkstra_shortest_paths(g, srcs, distmx=weights(g));

Perform [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
on a graph, computing shortest distances between `srcs` and all other vertices.
Return a [`LightGraphs.DijkstraState`](@ref) that contains various traversal information.

### Optional Arguments
- `allpaths=false`: If true, returns a [`LightGraphs.DijkstraState`](@ref) that keeps track of all
predecessors of a given vertex.

### Performance
If using a sparse matrix for `distmx`, you *may* achieve better performance by passing in a transpose of its sparse transpose.
That is, assuming `D` is the sparse distance matrix:
```
D = transpose(sparse(transpose(D)))
```
Be aware that realizing the sparse transpose of `D` incurs a heavy one-time penalty, so this strategy should only be used
when multiple calls to `dijkstra_shortest_paths` with the distance matrix are planned.

# Examples
```jldoctest
julia> using LightGraphs

julia> ds = dijkstra_shortest_paths(cycle_graph(5), 2);

julia> ds.dists
5-element Array{Int64,1}:
 1
 0
 1
 2
 2

julia> ds = dijkstra_shortest_paths(path_graph(5), 2);

julia> ds.dists
5-element Array{Int64,1}:
 1
 0
 1
 2
 3
```
"""
function shortest_paths(g::AbstractGraph, srcs::Vector{U}, distmx::AbstractMatrix{T}, alg::Dijkstra) where {T<:Real, U<:Integer}
    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    visited = zeros(Bool, nvg)

    pathcounts = zeros(UInt64, nvg)
    preds = fill(Vector{U}(), nvg)
    H = PriorityQueue{U,T}()
    # fill creates only one array.

    for src in srcs
        dists[src] = zero(T)
        visited[src] = true
        pathcounts[src] = 1
        H[src] = zero(T)
    end

    closest_vertices = Vector{U}()  # Maintains vertices in order of distances from source
    sizehint!(closest_vertices, nvg)

    while !isempty(H)
        u = dequeue!(H)

        if alg.track_vertices
            push!(closest_vertices, u)
        end

        d = dists[u] # Cannot be typemax if `u` is in the queue
        for v in outneighbors(g, u)
            alt = d + distmx[u, v]

            if !visited[v]
                visited[v] = true
                dists[v] = alt
                parents[v] = u

                pathcounts[v] += pathcounts[u]
                if alg.all_paths
                    preds[v] = [u;]
                end
                H[v] = alt
            elseif alt < dists[v]
                dists[v] = alt
                parents[v] = u
                #615
                pathcounts[v] = pathcounts[u]
                if alg.all_paths
                    resize!(preds[v], 1)
                    preds[v][1] = u
                end
                H[v] = alt
            elseif alt == dists[v]
                pathcounts[v] += pathcounts[u]
                if alg.all_paths
                    push!(preds[v], u)
                end
            end
        end
    end

    if alg.track_vertices
        for s in vertices(g)
            if !visited[s]
                push!(closest_vertices, s)
            end
        end
    end

    for src in srcs
        pathcounts[src] = 1
        parents[src] = 0
        empty!(preds[src])
    end

    return DijkstraResults{T, U}(parents, dists, preds, pathcounts, closest_vertices)
end

shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix, alg::Dijkstra) = shortest_paths(g, [s], distmx, alg)
# If we don't specify an algorithm, use dijkstra.
shortest_paths(g::AbstractGraph, s, distmx::AbstractMatrix) = shortest_paths(g, s, distmx, Dijkstra())

