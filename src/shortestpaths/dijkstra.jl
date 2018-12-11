"""
    struct DijkstraState{T, U}

An [`AbstractPathState`](@ref) designed for Dijkstra shortest-paths calculations.
"""
struct DijkstraState{T <: Real,U <: Integer} <: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
    predecessors::Vector{Vector{U}}
    pathcounts::Vector{UInt64}
    closest_vertices::Vector{U}
end

"""
    dijkstra_shortest_paths(g, srcs, distmx=weights(g));

Perform [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
on a graph, computing shortest distances between `srcs` and all other vertices.
Return a [`LightGraphs.DijkstraState`](@ref) that contains various traversal information.

### Optional Arguments
- `allpaths=false`: If true, returns a [`LightGraphs.DijkstraState`](@ref) that keeps track of all
predecessors of a given vertex.
- `trackvertices=false`: If true, returns a [`LightGraphs.DijkstraState`](@ref) that keeps track of the
order of insertion into the priority queue (i.e. distance from source). Vertices not reachable from source
are appended to the end of the list.

### Performance
Use a matrix type for `distmx` that is implemented in [row-major matrix format](https://en.wikipedia.org/wiki/Row-_and_column-major_order)
for better run-time.
Eg. Set the type of `distmx` to `Transpose{Int64, SparseMatrixCSC{Int64,Int64}}`
instead of `SparseMatrixCSC{Int64,Int64}`.

# Examples
```jldoctest
julia> using LightGraphs

julia> ds = dijkstra_shortest_paths(CycleGraph(5), 2);

julia> ds.dists
5-element Array{Int64,1}:
 1
 0
 1
 2
 2

julia> ds = dijkstra_shortest_paths(PathGraph(5), 2);

julia> ds.dists
5-element Array{Int64,1}:
 1
 0
 1
 2
 3
```
"""
function dijkstra_shortest_paths(g::AbstractGraph,
    srcs::Vector{U},
    distmx::AbstractMatrix{T}=weights(g);
    allpaths=false,
    trackvertices=false
    ) where T <: Real where U <: Integer

    nvg = nv(g)
    @boundscheck checkbounds(distmx, Base.OneTo(nvg), Base.OneTo(nvg))

    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    visited = zeros(Bool, nvg)

    pathcounts = zeros(UInt64, nvg)
    preds = fill(Vector{U}(), nvg) # fill creates only one array.
    pq = PriorityQueue{U,T}()

    for src in srcs
        dists[src] = zero(T)
        pathcounts[src] = 1
        pq[src] = zero(T)
        preds[src] = []
    end

    closest_vertices = Vector{U}()  #maintains vertices in order of distances from source
    sizehint!(closest_vertices, nvg)

    @inbounds while !isempty(pq)
        u, d = dequeue_pair!(pq) #(u, distance of u)
        dists[u] = d
        visited[u] = true

        if trackvertices
            push!(closest_vertices, u)
        end

        for v in outneighbors(g, u)
            alt = d + distmx[u, v] #new distance to v via u

            if alt < dists[v] #not visited or found a shorter path to visit
                (visited[v]) && error("Negative weight cycle detected in Dijkstra's Algorithm.")
                dists[v] = alt
                parents[v] = u
                pathcounts[v] = pathcounts[u]
                pq[v] = alt

                if allpaths
                    if isassigned(preds[v], 1)
                        resize!(preds[v], 1)
                        preds[v][1] = u
                    else #first time accessing vertex v
                        preds[v] = [u]
                    end
                end
            elseif alt == dists[v]
                pathcounts[v] += pathcounts[u]
                if allpaths
                    push!(preds[v], u)
                end
            end
        end
    end

    if trackvertices
        @inbounds for s in vertices(g)
            if !visited[s]
                push!(closest_vertices, s)
            end
        end
    end

    return DijkstraState{T,U}(parents, dists, preds, pathcounts, closest_vertices)
end

dijkstra_shortest_paths(g::AbstractGraph, src::Integer, distmx::AbstractMatrix=weights(g); allpaths=false, trackvertices=false) =
dijkstra_shortest_paths(g, [src;], distmx; allpaths=allpaths, trackvertices=trackvertices)
