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

# function parallel_dijkstra_shortest_paths!{T}(
#     fm::AbstractArray,
#     si::Int,
#     src::Int,
#     distmx::AbstractArray,
#     allpaths::Bool,
#     parents::SharedArray{Int, Int},
#     dists::SharedArray{T, Int},
#     pathcounts::SharedArray{Int, Int},
#     # preds::SharedSparseMatrixCSC{Bool, Int}
#     )
#     info("starting p_d_s_p!: si = $si, src = $src, dists.n = $(dists.n), [3,1] = $(dists[3,1]), T = $T")
#     nvg = fm.m
#     info("past 181")
#     visited = zeros(Bool, nvg)
#     H = DijkstraHeapEntry{T}[]  # this should be Vector{T}() in 0.4, I think.
#     info("past 184")
#     sizehint!(H, nvg)
#     info("past 186 - dists[src,si] = $(dists[src,si])")
#     dists[src, si] = 0
#     info("past 188")
#     pathcounts[src, si] = 1
#     info("past 190")
#     heappush!(H, DijkstraHeapEntry{T}(src, dists[src, si]))
#
#     while !isempty(H)
#         hentry = heappop!(H)
#         info("Popped H - got $(hentry.vertex)")
#         u = hentry.vertex
#         for v in _column(fm, u)  # out neighbors of vector u
#             alt = (dists[u, si] == typemax(T))? typemax(T) : dists[u, si] + distmx[v,u]
#
#             if !visited[v]
#                 dists[v, si] = alt
#                 parents[v, si] = u
#                 pathcounts[v, si] += pathcounts[u, si]
#                 visited[v] = true
#                 # if allpaths
#                 #     preds[v,u, si] = true
#                 # end
#                 heappush!(H, DijkstraHeapEntry{T}(v, alt))
#                 info("Pushed $v, $alt")
#             else
#                 if alt < dists[v, si]
#                     dists[v, si] = alt
#                     parents[v, si] = u
#                     heappush!(H, DijkstraHeapEntry{T}(v, alt))
#                 end
#                 if alt == dists[v, src]
#                     pathcounts[v, src] += pathcounts[u, si]
#                     # if allpaths
#                     #     preds[v,u, src] = true
#                     # end
#                 end
#             end
#         end
#     end
#
#     dists[src, si] = zero(T)
#     pathcounts[src, si] = 1
#     parents[src, si] = 0
#     # preds[src, :, src] = fill(false, nvg)
#
#     return true
# end
#
#
# function parallel_dsp{T}(g::AbstractSparseGraph, srcs::Vector{Int}, distmx::AbstractArray{T,2}=DefaultDistance(); allpaths=false)
#     n_v = nv(g)
#     ls = length(srcs)
#     shparents = share(spzeros(Int, n_v, ls))
#     shdists = share(spzeros(T, n_v, ls))
#     shpathcounts = share(spzeros(Int, n_v, ls))
#     # shpreds = SharedArray(Bool, (n_v,n_v,ls),init=s->s[localindexes(s)] = false)
#     states = Vector{DijkstraState}(ls)
#     # sharedmx = share(g.fm .* distmx[1:nv(g), 1:nv(g)])
#
#     # nprox = nworkers()
#     #
#     # (ls_perproc, r) = divrem(ls,nprox)
#     # startsplits = collect(1:ls_perproc:ls)
#     # if r > 0
#     #     startsplits = startsplits[1:end-1]
#     # end
#     # endsplits = startsplits + (ls_perproc -1)
#     # endsplits[end] = ls
#     # splits = [x:y for (x,y) in zip(startsplits, endsplits)]
#     # info("splits = $splits")
#     @sync @parallel for i in 1:ls
#         info("processing $i")
#         parallel_dijkstra_shortest_paths!(
#             fmat(g),
#             i,
#             srcs[i],
#             distmx,
#             allpaths,
#             shparents,
#             shdists,
#             shpathcounts,
#             # shpreds
#         )
#         info("ending $i")
#         nothing
#     end
#
#     # for i in 1:ls
#     #     predecessors = Vector{Vector{Int}}()
#     #     preds = sparse(shpreds[:,:,i])
#     #     for c in 1:preds.m
#     #         push!(predecessors, _column(preds, c))
#     #     end
#     predecessors = Vector{Vector{Int}}()
#     for i in 1:ls
#         push!(predecessors,Vector{Int}())
#     end
#
#     for i in 1:ls
#         states[i] = DijkstraState(shparents[:,i], shdists[:,i], predecessors, shpathcounts[:,i])
#     end
#     return states
# end
#
#
# function ptest!(x::AbstractArray, i::Int)
#     info("x.m = $(x.m), vx = $i")
# end
# function ptest(g::AbstractSparseGraph)
#     @sync @parallel for i = 1:nv(g)
#         ptest!(g.fm, i)
#     end
# end

function pdsp{T}(g::AbstractSparseGraph, srcs::Vector{Int}, distmx::AbstractArray{T,2}=DefaultDistance(nv(g)); allpaths=false)
    ls = length(srcs)
    fm = share(g.fm)
    states = @sync @parallel vcat for i = 1:ls
        dijkstra_shortest_paths_sparse(fm, i, distmx, allpaths)
    end
    return states
end
