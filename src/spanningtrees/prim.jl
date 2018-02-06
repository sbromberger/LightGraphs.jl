struct PrimHeapEntry{T<:AbstractEdge, U<:Real}
    edge::T
    dist::U
end

isless(e1::PrimHeapEntry, e2::PrimHeapEntry) = e1.dist < e2.dist

"""
    prim_mst(g, distmx=weights(g))

Return a vector of edges representing the minimum spanning tree of a connected, undirected graph `g` with optional
distance matrix `distmx` using [Prim's algorithm](https://en.wikipedia.org/wiki/Prim%27s_algorithm).
Return a vector of edges.
"""
function prim_mst end
@traitfn function prim_mst{T<:AbstractEdge, U<:Real, V, AG<:AbstractGraph{T}}(
    g::AG::(!IsDirected),
    distmx::AbstractMatrix{U} = weights(g)
    )
    pq = Vector{PrimHeapEntry{T, U}}()
    mst = Vector{T}()
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
    visit!(g, v, marked, pq, distmx)

Mark the vertex `v` of graph `g` true in the array `marked` and enter all its
edges into priority queue `pq` with its `distmx` values as a PrimHeapEntry.
"""
function visit!(
    g::AbstractGraph,
    v::Integer,
    marked::AbstractVector{Bool},
    pq::AbstractVector{PrimHeapEntry{T, U}},
    distmx::AbstractMatrix
) where {T<:AbstractEdge, U<:Real}
    marked[v] = true
    for w in outneighbors(g, v)
        if !marked[w]
            x = min(v, w)
            y = max(v, w)
            heappush!(pq, PrimHeapEntry{T, U}(T(x, y), distmx[x, y]))
        end
    end
end
