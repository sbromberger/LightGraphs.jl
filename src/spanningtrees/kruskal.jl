struct KruskalHeapEntry{T<:Real}
    edge::Edge
    dist::T
end

isless(e1::KruskalHeapEntry, e2::KruskalHeapEntry) = e1.dist < e2.dist

"""
    quick_find!(nodes, p, q)

Perform [Quick-Find algorithm](https://en.wikipedia.org/wiki/Disjoint-set_data_structure)
on a given pair of nodes `p`and `q`, and make a connection between them in the vector `nodes`.
"""
function quick_find!(nodes, p, q)
    pid = nodes[p]
    qid = nodes[q]
    for i in 1:length(nodes)
        if nodes[i] == pid
            nodes[i] = qid
        end
    end
end

"""
    kruskal_mst(g, distmx=DefaultDistance())

Return a vector of edges representing the minimum spanning tree of a connected, undirected graph `g` with optional
distance matrix `distmx` using [Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm).
"""
function kruskal_mst end
@traitfn function kruskal_mst{T}(
    g::::(!IsDirected),
    distmx::AbstractMatrix{T} = DefaultDistance()
)

    U = eltype(g)
    edge_list = Vector{KruskalHeapEntry{T}}()
    mst = Vector{Edge}()
    connected_nodes = collect(one(U):nv(g))

    sizehint!(edge_list, ne(g))
    sizehint!(mst, ne(g))

    for e in edges(g)
        heappush!(edge_list, KruskalHeapEntry{T}(e, distmx[src(e), dst(e)]))
    end

    while !isempty(edge_list) && length(mst) < nv(g) - 1
        heap_entry = heappop!(edge_list)
        v = src(heap_entry.edge)
        w = dst(heap_entry.edge)

        if connected_nodes[v] != connected_nodes[w]
            quick_find!(connected_nodes, v, w)
            push!(mst, heap_entry.edge)
        end
    end

    return mst
end
