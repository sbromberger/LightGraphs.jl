"""
    prim_mst(g, distmx=weights(g))

Return a vector of edges representing the minimum spanning tree of a connected, undirected graph `g` with optional
distance matrix `distmx` using [Prim's algorithm](https://en.wikipedia.org/wiki/Prim%27s_algorithm).
Return a vector of edges.
"""
function prim_mst end
@traitfn function prim_mst(g::AG::(!IsDirected),
    distmx::AbstractMatrix{T}=weights(g)) where {T <: Real, U, AG <: AbstractGraph{U}}
    
    nvg = nv(g)

    pq = PriorityQueue{U, T}()
    finished = zeros(Bool, nvg)
    wt = fill(typemax(T), nvg) #Faster access time
    parents = zeros(U, nv(g))

    pq[1] = typemin(T)
    wt[1] = typemin(T)

    while !isempty(pq)
        v = dequeue!(pq)
        finished[v] = true

        for u in neighbors(g, v)
            finished[u] && continue
            
            if wt[u] > distmx[u, v]
                wt[u] = distmx[u, v] 
                pq[u] = wt[u]
                parents[u] = v
            end
        end
    end

    return [Edge{U}(parents[v], v) for v in vertices(g) if parents[v] != 0]
end


export parallel_prim_mst
function parallel_prim_mst end
@traitfn function parallel_prim_mst(g::AG::(!IsDirected),
    distmx::AbstractMatrix{T}=weights(g)) where {T <: Real, U, AG <: AbstractGraph{U}}
    
    nvg = nv(g)

    bpq = BatchPriorityQueue(nvg, T)
    finished = zeros(Bool, nvg)
    visited = zeros(Bool, nvg)
    wt = fill(typemax(T), nvg) #Faster access time
    parents = zeros(U, nv(g))


    enqueue!(bpq, Pair{U, T}(one(U), typemin(T)))
    visited[1] = true
    wt[1] = typemin(T)


    update_best_ind(bpq)
    while !isempty(bpq)
        v = dequeue!(bpq)

        finished[v] = true

       
        for u in neighbors(g, v)

            finished[u] && continue

            if !visited[u]
                enqueue!(bpq, Pair{U, T}(u, distmx[u, v]))
                visited[u] = true
                wt[u] = distmx[u, v]
                parents[u] = v
            else
                if wt[u] > distmx[u, v]
                    wt[u] = distmx[u, v]
                    parents[u] = v
                    queue_decrease_key!(bpq, u)
                end 
            end
        end 
        batch_decrease_key!(bpq, wt)
        update_best_ind(bpq)
    end

    return [Edge{U}(parents[v], v) for v in vertices(g) if parents[v] != 0]
end