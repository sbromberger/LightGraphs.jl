struct PrimHeapEntry{T <: Real}
    edge::Edge
    dist::T
end

isless(e1::PrimHeapEntry, e2::PrimHeapEntry) = e1.dist < e2.dist

"""
    prim_mst(g, distmx=weights(g))

Return a vector of edges representing the minimum spanning tree of a connected, undirected graph `g` with optional
distance matrix `distmx` using [Prim's algorithm](https://en.wikipedia.org/wiki/Prim%27s_algorithm).
Return a vector of edges.
"""
function prim_mst end
@traitfn function prim_mst(g::AG::(!IsDirected),
    distmx::AbstractMatrix{T}=weights(g)) where {T <: Real, U, AG <: AbstractGraph{U}}
    pq = Vector{PrimHeapEntry{T}}()
    mst = Vector{Edge}()
    marked = zeros(Bool, nv(g))

    sizehint!(pq, ne(g))
    sizehint!(mst, nv(g) - 1)
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
function visit!(g::AbstractGraph,
    v::Integer,
    marked::AbstractVector{Bool},
    pq::AbstractVector,
    distmx::AbstractMatrix)
    marked[v] = true
    for w in outneighbors(g, v)
        if !marked[w]
            x = min(v, w)
            y = max(v, w)
            heappush!(pq, PrimHeapEntry(Edge(x, y), distmx[x, y]))
        end
    end
end


export parallel_prim_mst
function parallel_prim_mst end
@traitfn function parallel_prim_mst(g::AG::(!IsDirected),
    distmx::AbstractMatrix{T}=weights(g)) where {T <: Real, U, AG <: AbstractGraph{U}}
    
    nvg = nv(g)

    bpq = BatchPriorityQueue(nvg, T)
    mst = Vector{Edge}()
    sizehint!(mst, nvg - 1)

    visited = zeros(Bool, nvg)
    wt = fill(typemax(T), nvg)
    finished = zeros(Bool, nvg)

    enqueue!(bpq, Pair{U, T}(one(U), zero(T)))
    visited[1] = true
    wt[1] = 0
    finished[1] = true

    edge_partner = zeros(U, nv(g))

    update_best_ind(bpq)
    while !isempty(bpq)
        v = dequeue!(bpq)
        w = edge_partner[v]

        finished[v] = true

        if has_vertex(g, w)
            push!(mst, Edge(w, v))
        end

        for u in neighbors(g, v)

            finished[u] && continue

            if !visited[u]
                enqueue!(bpq, Pair{U, T}(u, distmx[u, v]))
                edge_partner[u] = v
                visited[u] = true
            else
                if wt[u] > distmx[u, v]
                    wt[u] = distmx[u, v]
                    edge_partner[u] = v
                    queue_decrease_key!(bpq, u)
                end 
            end
        end 
        batch_decrease_key!(bpq, wt)
        update_best_ind(bpq)
    end

    return mst
end