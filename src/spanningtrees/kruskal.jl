struct KruskalHeapEntry{T<:AbstractEdge, U<:Real}
    edge::T
    dist::U
end

isless(e1::KruskalHeapEntry, e2::KruskalHeapEntry) = e1.dist < e2.dist

"""
    quick_find!(vs, p, q)

Perform [Quick-Find algorithm](https://en.wikipedia.org/wiki/Disjoint-set_data_structure)
on a given pair of vertices `p`and `q`, and make a connection between them in the vector `vs`.
"""
function quick_find!(vs, p, q)
    pid = vs[p]
    qid = vs[q]
    for i in 1:length(vs)
        if vs[i] == pid
            vs[i] = qid
        end
    end
end

"""
    kruskal_mst(g, distmx=weights(g))

Return a vector of edges representing the minimum spanning tree of a connected, undirected graph `g` with optional
distance matrix `distmx` using [Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm).
"""
function kruskal_mst end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function kruskal_mst{T<:AbstractEdge, U, V, AG<:AbstractGraph{U}}(
    g::AG::(!IsDirected),
    distmx::AbstractMatrix{T} = weights(g)
)

    edge_list = Vector{KruskalHeapEntry{T, U}}()
    mst = Vector{T}()
    connected_vs = collect(one(V):nv(g))

    sizehint!(edge_list, ne(g))
    sizehint!(mst, ne(g))

    for e in edges(g)
        heappush!(edge_list, KruskalHeapEntry{T, U}(e, distmx[src(e), dst(e)]))
    end

    while !isempty(edge_list) && length(mst) < nv(g) - 1
        heap_entry = heappop!(edge_list)
        v = src(heap_entry.edge)
        w = dst(heap_entry.edge)

        if connected_vs[v] != connected_vs[w]
            quick_find!(connected_vs, v, w)
            push!(mst, heap_entry.edge)
        end
    end

    return mst
end
