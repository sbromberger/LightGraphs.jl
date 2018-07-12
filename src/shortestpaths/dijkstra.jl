"""
    struct DijkstraState{T, U}

An [`AbstractPathState`](@ref) designed for Dijkstra shortest-paths calculations.
"""
struct DijkstraState{T <: Real,U <: Integer} <: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
    predecessors::Vector{Vector{U}}
    pathcounts::Vector{U}
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

### Performance
Use a matrix type for `distmx` that is implemented in [row-major matrix format](https://en.wikipedia.org/wiki/Row-_and_column-major_order) 
for better run-time.
Eg. Set the type of `distmx` to `Transpose{Int64, SparseMatrixCSC{Int64,Int64}}` 
instead of `SparseMatrixCSC{Int64,Int64}`.
"""
function dijkstra_shortest_paths(g::AbstractGraph,
    srcs::Vector{U},
    distmx::AbstractMatrix{T}=weights(g);
    allpaths=false,
    trackvertices=false
    ) where T <: Real where U <: Integer

    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    visited = zeros(Bool, nvg)

    pathcounts = zeros(Int, nvg)
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

        if trackvertices
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
                if allpaths
                    preds[v] = [u;]
                end
                H[v] = alt
            elseif alt < dists[v]
                dists[v] = alt
                parents[v] = u
                #615
                pathcounts[v] = pathcounts[u]
                if allpaths
                    resize!(preds[v], 1)
                    preds[v][1] = u
                end
                H[v] = alt
            elseif alt == dists[v]
                pathcounts[v] += pathcounts[u]
                if allpaths
                    push!(preds[v], u)
                end
            end
        end
    end

    if trackvertices
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

    return DijkstraState{T,U}(parents, dists, preds, pathcounts, closest_vertices)
end

dijkstra_shortest_paths(g::AbstractGraph, src::Integer, distmx::AbstractMatrix=weights(g); allpaths=false, trackvertices=false) =
dijkstra_shortest_paths(g, [src;], distmx; allpaths=allpaths, trackvertices=trackvertices)

"""
    struct MultipleDijkstraState{T, U}

An [`AbstractPathState`](@ref) designed for multisource_dijkstra_shortest_paths calculation.
"""
struct MultipleDijkstraState{T <: Real,U <: Integer} <: AbstractPathState
    dists::Matrix{T}
    parents::Matrix{U}
end

"""
    parallel_multisource_dijkstra_shortest_paths(g, sources=vertices(g), distmx=weights(g))

Compute the shortest paths between all pairs of vertices in graph `g` by running
[`dijkstra_shortest_paths`] for every vertex and using an optional list of source vertex `sources` and
an optional distance matrix `distmx`. Return a [`MultipleDijkstraState`](@ref) with relevant
traversal information.
"""
function parallel_multisource_dijkstra_shortest_paths(g::AbstractGraph{U},
    sources::AbstractVector=vertices(g),
    distmx::AbstractMatrix{T}=weights(g)) where T <: Real where U

    n_v = nv(g)
    r_v = length(sources)

    # TODO: remove `Int` once julialang/#23029 / #23032 are resolved
    dists   = SharedMatrix{T}(Int(r_v), Int(n_v))
    parents = SharedMatrix{U}(Int(r_v), Int(n_v))

    @sync @distributed for i in 1:r_v
        state = dijkstra_shortest_paths(g, sources[i], distmx)
        dists[i, :] = state.dists
        parents[i, :] = state.parents
    end

    result = MultipleDijkstraState(sdata(dists), sdata(parents))
    return result
end
