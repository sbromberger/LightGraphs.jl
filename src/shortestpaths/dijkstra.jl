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
    g::SimpleGraph,
    srcs::Vector{Int},
    distmx::AbstractArray{T, 2}=DefaultDistance();
    allpaths=false
)
    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(Int, nvg)
    preds = fill(Int[],nvg)
    visited = zeros(Bool, nvg)
    pathcounts = zeros(Int, nvg)
    H = DijkstraHeapEntry{T}[]  # this should be Vector{T}() in 0.4, I think.
    dists[srcs] = zero(T)
    pathcounts[srcs] = 1

    sizehint!(H, nvg)

    for v in srcs
        heappush!(H, DijkstraHeapEntry{T}(v, dists[v]))
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
                # info("Pushed $v, $alt")
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

    dists[srcs] = zero(T)
    pathcounts[srcs] = 1
    parents[srcs] = 0
    for src in srcs
        preds[src] = []
    end

    return DijkstraState{T}(parents, dists, preds, pathcounts)
end

dijkstra_shortest_paths{T}(g::SimpleGraph, src::Int, distmx::AbstractArray{T,2}=DefaultDistance(); allpaths=false) =
  dijkstra_shortest_paths(g, [src;], distmx; allpaths=allpaths)

function dijkstra_shortest_paths_sparse{T<:Real}(
    sparsemx::SharedSparseMatrixCSC{Bool, Int},
    src::Int,
    distmx::AbstractArray{T,2},
    allpaths=false
)
    nvg = sparsemx.m
    dists = fill(typemax(T), nvg)
    parents = zeros(Int, nvg)
    preds = fill(Int[],nvg)
    visited = zeros(Bool, nvg)
    pathcounts = zeros(Int, nvg)
    H = DijkstraHeapEntry{T}[]  # this should be Vector{T}() in 0.4, I think.
    dists[src] = zero(T)
    pathcounts[src] = 1

    sizehint!(H, nvg)


    heappush!(H, DijkstraHeapEntry{T}(src, dists[src]))

    while !isempty(H)
        hentry = heappop!(H)
        # info("Popped H - got $(hentry.vertex)")
        u = hentry.vertex
        for v in _column(sparsemx, u)  # out neighbors of vector u
            alt = (dists[u] == typemax(T))? typemax(T) : dists[u] + distmx[v,u]

            if !visited[v]
                dists[v] = alt
                parents[v] = u
                pathcounts[v] += pathcounts[u]
                visited[v] = true
                if allpaths
                    preds[v] = [u;]
                end
                heappush!(H, DijkstraHeapEntry{T}(v, alt))
                # info("Pushed $v, $alt")
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

    dists[src] = zero(T)
    pathcounts[src] = 1
    parents[src] = 0
    preds[src] = []


    return DijkstraState{T}(parents, dists, preds, pathcounts)
end

function dijkstra_shortest_paths_sparse_range{T}(
    weighted_shared_mx::SharedSparseMatrixCSC{T, Int},
    srcs::Vector{Int},
    offset::Int,
    allpaths=false
)
    statesdict = Dict{Int, DijkstraState}()
    for (i,s) in enumerate(srcs)
        # info("in range: processing vector $s")
        statesdict[offset+i] = dijkstra_shortest_paths_sparse(weighted_shared_mx, s)
    end
    return statesdict
end


function parallel_dsp{T}(g::AbstractSparseGraph, srcs::Vector{Int}, distmx::AbstractArray{T,2}=DefaultDistance(); allpaths=false)

    states = Vector{DijkstraState}(length(srcs))
    sharedmx = share(g.fm .* distmx[1:nv(g), 1:nv(g)])
    nprox = nworkers()
    ls = length(srcs)
    (ls_perproc, r) = divrem(ls,nprox)
    startsplits = collect(1:ls_perproc:ls)
    if r > 0
        startsplits = startsplits[1:end-1]
    end
    endsplits = startsplits + (ls_perproc -1)
    endsplits[end] = ls
    splits = [x:y for (x,y) in zip(startsplits, endsplits)]
    info("splits = $splits")
    i_states = @parallel (merge) for i in splits
        info("processing $i")
        z = dijkstra_shortest_paths_sparse_range(sharedmx, [i;], start(i)-1, allpaths)
        info("ending $i")
        z
    end
    @sync begin
        for (ind, state) in i_states
            states[ind] = state
        end
    end

    return states
end
