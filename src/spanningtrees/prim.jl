immutable PrimHeapEntry{T<:Real}
    edge::Edge
    dist::T
end

isless(e1::PrimHeapEntry, e2::PrimHeapEntry) = e1.dist < e2.dist

"""Performs [Prim's algorithm](https://en.wikipedia.org/wiki/Prim%27s_algorithm)
on a connected, non-directional graph `g`, having adjacency matrix `distmx`,
and computes minimum spanning tree. Returns a `Vector{Edge}`,
that contains the edges.
"""
function prim_mst{T<:Real}(
    g::SimpleGraph,
    distmx::AbstractArray{T, 2} = DefaultDistance()
    ) :: Vector{Edge}

    pq = Vector{PrimHeapEntry{T}}()
    mst = Vector{Edge}()
    marked = zeros(Bool, nv(g))

    sizehint!(pq, ne(g))
    sizehint!(mst, ne(g))
    visit!(g, 1, marked, pq, distmx)

    while !isempty(pq)
        heap_entry = heappop!(pq)
        v = src(heap_entry.edge)
        w = dst(heap_entry.edge)

        marked[v] && marked[w] && continue
        push!(mst, heap_entry.edge)

        !marked[v] && visit!(g, v, marked, pq, distmx)
        !marked[w] && visit!(g, w, marked, pq, distmx)
    end

    return mst
end

"""
Used to mark the visited vertices. Marks the vertex `v` of graph `g` true in the array `marked`
and enters all its edges into priority queue `pq` with its `distmx` values as a PrimHeapEntry.
"""
function visit!{T<:Real}(
    g::SimpleGraph,
    v::Int,
    marked::AbstractArray{Bool, 1},
    pq::Vector{PrimHeapEntry{T}},
    distmx::AbstractArray{T, 2}
)
    marked[v] = true
    for w in fadj(g)[v]
        if !marked[w]
            x = min(v, w)
            y = max(v, w)
            heappush!(pq, PrimHeapEntry(Edge(x, y), distmx[x, y]))
        end
    end
end
