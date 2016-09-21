immutable KruskalHeapEntry{T}
    edge::Pair{Int, Int}
    dist::T
end

isless(e1::KruskalHeapEntry, e2::KruskalHeapEntry) = e1.dist < e2.dist

""" Performs Quick-Find algorithm
to check for connected vertices
"""
function quick_find(nodes, p, q)
    pid = nodes[p]
    qid = nodes[q]
    for i in 1:length(nodes)
        if nodes[i] == pid
            nodes[i] = qid
        end
    end
end

function check_connected(nodes, p, q)

    return nodes[p] == nodes[q]
end

"""Kruskal's algorithm
to find minimum spanning tree for undirected graphs
"""
function kruskal_mst{T}(
    g::SimpleGraph,
    distmx::AbstractArray{T, 2}
)

    edge_list = []
    mst = []
    connected_nodes = Vector{Int}(1:nv(g))

    for e in edges(g)
        println(e)
        heappush!(edge_list, KruskalHeapEntry{T}(e, distmx[src(e), dst(e)]))
    end

    while !isempty(edge_list) && length(mst) < nv(g) - 1
        e = heappop!(edge_list)
        v = src(e.edge)
        w = dst(e.edge)

        if !check_connected(connected_nodes, v, w)
            quick_find(connected_nodes, v, w)
            push!(mst, e)
        end
    end

    return mst
end
