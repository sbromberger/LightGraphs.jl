struct KruskalHeapEntry{T<:Real}
    edge::Edge
    dist::T
end

isless(e1::KruskalHeapEntry, e2::KruskalHeapEntry) = e1.dist < e2.dist

"""
    find_set!(vs, q)

Perform [Quick-Find algorithm](https://en.wikipedia.org/wiki/Disjoint-set_data_structure)
on a given vertex `q` and return the component id in `vs` to which it belongs.
"""
function find_set!(set_id::Vector{U}, q::U) where U<:Integer
    
    root = q
    while root != set_id[root]
        root = set_id[root]
    end

    p_1 = q
    p_2 = set_id[q]
    
    while p_2 != root
        set_id[p_1] = root
        p_1 = p_2
        p_2 = set_id[p_1]
    end
    
    return root
end

union_set!{U<:Integer}(set_id::Vector{U}, p::U, q::U) = (set_id[find_set!(set_id, p)] = find_set!(set_id, q))

"""
    kruskal_mst(g, distmx=weights(g))

Return a vector of edges representing the minimum spanning tree of a connected, undirected graph `g` with optional
distance matrix `distmx` using [Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm).
"""
function kruskal_mst end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function kruskal_mst{T<:Real, U, AG<:AbstractGraph{U}}(
    g::AG::(!IsDirected),
    distmx::AbstractMatrix{T} = weights(g)
)

    edge_list = Vector{KruskalHeapEntry{T}}()
    mst = Vector{Edge}()
    connected_vs = collect(one(U):nv(g))

    sizehint!(edge_list, ne(g))
    sizehint!(mst, nv(g) - 1)

    for e in edges(g)
        push!(edge_list, KruskalHeapEntry{T}(Edge(src(e), dst(e)), distmx[src(e), dst(e)]))
    end
    heapify!(edge_list)

    while !isempty(edge_list)
        heap_entry = heappop!(edge_list)
        v = src(heap_entry.edge)
        w = dst(heap_entry.edge)

        if find_set!(connected_vs, v) != find_set!(connected_vs, w)
            union_set!(connected_vs, v, w)
            push!(mst, heap_entry.edge)
            if length(mst) >= nv(g) - 1
                break
            end
        end
    end

    return mst
end

