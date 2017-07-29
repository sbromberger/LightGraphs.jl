"""
    struct DijkstraState{T, U}

An [`AbstractPathState`](@ref) designed for Dijkstra shortest-paths calculations.
"""
struct DijkstraState{T,U<:Integer} <: AbstractPathState
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
Return a [`DijkstraState`](@ref) that contains various traversal information.

### Optional Arguments
- `allpaths=false`: If true, returns a [`DijkstraState`](@ref) that keeps track of all
predecessors of a given vertex.
"""
function dijkstra_shortest_paths(
    g::AbstractGraph,
    srcs::Vector{U},
    distmx::AbstractMatrix{T}=weights(g);
    allpaths=false,
    trackvertices=false
    ) where T where U<:Integer

    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    preds = fill(Vector{U}(), nvg)
    visited = zeros(Bool, nvg)
    pathcounts = zeros(Int, nvg)
    H = PriorityQueue{U,T,Base.Order.ForwardOrdering}() # this should be Vector{T}() in 0.4, I think.
    dists[srcs] = zero(T)
    pathcounts[srcs] = 1
    closest_vertices = Vector{U}()  # Maintains vertices in order of distances from source

    sizehint!(closest_vertices, nvg)

    for v in srcs
        H[v] = dists[v]
        visited[v] = true
    end

    while !isempty(H)
        hentry = dequeue_pair!(H)
            # info("Popped H - got $(hentry.vertex)")
        u = hentry[1]

        if trackvertices
          push!(closest_vertices, u)
        end

        for v in out_neighbors(g, u)
            alt = (dists[u] == typemax(T)) ? typemax(T) : dists[u] + distmx[u, v]

            if !visited[v]
                dists[v] = alt
                parents[v] = u
                pathcounts[v] += pathcounts[u]
                visited[v] = true
                if allpaths
                    preds[v] = [u;]
                end
                H[v] = alt
                # info("Pushed $v")
            else
                if alt < dists[v]
                    dists[v] = alt
                    parents[v] = u
                    #615
                    pathcounts[v] = 0
                    preds[v] = []
                    H[v] = alt
                end
                if alt == dists[v]
                    pathcounts[v] += pathcounts[u]
                    if allpaths
                        push!(preds[v], u)
                    end
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

    pathcounts[srcs] = 1
    parents[srcs] = 0
    for src in srcs
        preds[src] = []
    end

    return DijkstraState{T,U}(parents, dists, preds, pathcounts, closest_vertices)
end

dijkstra_shortest_paths(g::AbstractGraph, src::Integer, distmx::AbstractMatrix = weights(g); allpaths=false, trackvertices=false) =
dijkstra_shortest_paths(g, [src;], distmx; allpaths=allpaths, trackvertices=trackvertices)

"""
    struct MultipleDijkstraState{T, U}

An [`AbstractPathState`](@ref) designed for multisource_dijkstra_shortest_paths calculation.
"""
struct MultipleDijkstraState{T,U<:Integer} <: AbstractPathState
    dists::Matrix{T}
    parents::Matrix{U}
end

@doc_str """
    parallel_multisource_dijkstra_shortest_paths(g, sources=vertices(g), distmx=weights(g))

Compute the shortest paths between all pairs of vertices in graph `g` by running
[`dijkstra_shortest_paths`] for every vertex and using an optional list of source vertex `sources` and
an optional distance matrix `distmx`. Return a [`MultipleDijkstraState`](@ref) with relevant
traversal information.
"""

function parallel_multisource_dijkstra_shortest_paths(
    g::AbstractGraph,
    sources::AbstractVector = vertices(g),
    distmx::AbstractMatrix{T} = weights(g)
    ) where T

    U = eltype(g)
    n_v = nv(g)
    r_v = length(sources)

    dists   = SharedArray(zeros(T, r_v, n_v))
    parents = SharedArray(zeros(U, r_v, n_v))

    @sync @parallel for i in 1:r_v
      state = dijkstra_shortest_paths(g, sources[i], distmx)
      dists[i, :] = state.dists
      parents[i, :] = state.parents
    end

    result = MultipleDijkstraState(Matrix(dists), Matrix(parents))
    return result
end
