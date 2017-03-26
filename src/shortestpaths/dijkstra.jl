struct DijkstraHeapEntry{T, U<:Integer}
    vertex::U
    dist::T
end

isless(e1::DijkstraHeapEntry, e2::DijkstraHeapEntry) = e1.dist < e2.dist

"""
    struct DijkstraState{T, U}

An `AbstractPathState` designed for Dijkstra shortest-paths calculations.
"""
struct DijkstraState{T, U<:Integer}<: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
    predecessors::Vector{Vector{U}}
    pathcounts::Vector{U}
end

"""
dijkstra_shortest_paths(g, srcs, distmx=DefaultDistance());
    allpaths=false
    )
Perform [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
on a graph, computing shortest distances between `srcs` and all other nodes.
Return a `DijkstraState` that contains various traversal information.

### Optional arguments
- `allpaths=false`: If true, returns a `DijkstraState` that keeps track of all
predecessors of a given vertex.
"""
function dijkstra_shortest_paths(
    g::AbstractGraph,
    srcs::Vector{U},
    distmx::AbstractMatrix{T}=DefaultDistance();
    allpaths=false
    ) where T where U<:Integer
    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    preds = fill(Vector{U}(),nvg)
    visited = zeros(Bool, nvg)
    pathcounts = zeros(Int, nvg)
    H = Vector{DijkstraHeapEntry{T, U}}()  # this should be Vector{T}() in 0.4, I think.
    dists[srcs] = zero(T)
    pathcounts[srcs] = 1

    sizehint!(H, nvg)

    for v in srcs
        heappush!(H, DijkstraHeapEntry{T, U}(v, dists[v]))
        visited[v] = true
    end

    while !isempty(H)
        hentry = heappop!(H)
            # info("Popped H - got $(hentry.vertex)")
        u = hentry.vertex
        for v in out_neighbors(g,u)
            alt = (dists[u] == typemax(T))? typemax(T) : dists[u] + distmx[u,v]

            if !visited[v]
                dists[v] = alt
                parents[v] = u
                pathcounts[v] += pathcounts[u]
                visited[v] = true
                if allpaths
                    preds[v] = [u;]
                end
                heappush!(H, DijkstraHeapEntry{T, U}(v, alt))
                # info("Pushed $v")
            else
                if alt < dists[v]
                    dists[v] = alt
                    parents[v] = u
                    heappush!(H, DijkstraHeapEntry{T, U}(v, alt))
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

    pathcounts[srcs] = 1
    parents[srcs] = 0
    for src in srcs
        preds[src] = []
    end

    return DijkstraState{T, U}(parents, dists, preds, pathcounts)
end

dijkstra_shortest_paths(g::AbstractGraph, src::Integer, distmx::AbstractMatrix = DefaultDistance(); allpaths=false) =
dijkstra_shortest_paths(g, [src;], distmx; allpaths=allpaths)
