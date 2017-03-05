abstract AbstractDijkstraState<:AbstractPathState

immutable DijkstraHeapEntry{T}
    vertex::Int
    dist::T
end

isless(e1::DijkstraHeapEntry, e2::DijkstraHeapEntry) = e1.dist < e2.dist

type DijkstraState{T}<: AbstractDijkstraState
    parents::Vector{Int}
    dists::Vector{T}
    predecessors::Vector{Vector{Int}}
    pathcounts::Vector{Int}
end

"""Performs [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
on a graph, computing shortest distances between a source vertex `s` and all
other nodes. Returns a `DijkstraState` that contains various traversal
information (see below).

With `allpaths=true`, returns a `DijkstraState` that keeps track of all
predecessors of a given vertex (see below).
"""
function dijkstra_shortest_paths{T}(
    g::AbstractGraph,
    srcs::Vector{Int},
    distmx::AbstractArray{T, 2}=DefaultDistance();
    allpaths=false
)
    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(Int, nvg)
    preds = fill(Vector{Int}(),nvg)
    visited = zeros(Bool, nvg)
    pathcounts = zeros(Int, nvg)
    H = Vector{DijkstraHeapEntry{T}}()  # this should be Vector{T}() in 0.4, I think.
    dists[srcs] = zero(T)
    pathcounts[srcs] = 1

    sizehint!(H, nvg)

    for v in srcs
        heappush!(H, DijkstraHeapEntry{T}(v, dists[v]))
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
                heappush!(H, DijkstraHeapEntry{T}(v, alt))
                # info("Pushed $v")
            else
                if alt < dists[v]
                    dists[v] = alt
                    parents[v] = u
                    heappush!(H, DijkstraHeapEntry{T}(v, alt))
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

    return DijkstraState{T}(parents, dists, preds, pathcounts)
end

dijkstra_shortest_paths{T}(g::AbstractGraph, src::Int, distmx::AbstractArray{T,2}=DefaultDistance(); allpaths=false) =
  dijkstra_shortest_paths(g, [src;], distmx; allpaths=allpaths)
