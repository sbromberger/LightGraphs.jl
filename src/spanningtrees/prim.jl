immutable PrimHeapEntry{T<:Real}
    vertex::Int
    edge::Edge
    dist::T
end

isless(e1::PrimHeapEntry, e2::PrimHeapEntry) = e1.dist < e2.dist

"""
Checks whether a given vertex `v` is a member of a Vector{PrimHeapEntry}
and returns a tuple containing a Bool and the dist value.
"""
function contains{T<:Real}(pq::Vector{PrimHeapEntry{T}}, v::Int) :: Tuple{Bool, T}
    for item in pq
        v == item.vertex && return (true, item.dist)
    end
    return (false, zero(T))
end

"""
Updates the edge and dist values of a vertex `v` in a Vector{PrimHeapEntry} `pq`.
"""
function changeKey!{T<:Real}(pq::Vector{PrimHeapEntry{T}}, v::Int, e::Edge, new_dist::T)
    for item in pq
        if v == item.vertex
            deleteat!(pq, findin(pq, [item]))
            heappush!(pq,PrimHeapEntry(v, e, new_dist))
        end
    end
end

"""
Performs [Prim's algorithm](https://en.wikipedia.org/wiki/Prim%27s_algorithm)
on a connected, non-directional graph `g`, having adjacency matrix `distmx`,
and computes minimum spanning tree. Returns a `Vector{Edge}`,
that contains the edges. This is an eager implementation which requires only O(V) additional space
"""
function prim_mst{T<:Real}(g::AbstractGraph,
                            distmx::AbstractArray{T, 2} = DefaultDistance()
) :: Vector{Edge}
  
    pq = Vector{PrimHeapEntry{T}}()
    mst = Vector{Edge}()
    marked = fill(false, nv(g))

    sizehint!(pq, nv(g))
    sizehint!(mst, nv(g))

    visit!(g, 1, pq, distmx, marked)
    while size(mst)[1] < nv(g) - 1
        heap_entry = heappop!(pq)
        push!(mst, heap_entry.edge)
        visit!(g, heap_entry.vertex, pq, distmx, marked)
    end
    return mst
end

"""
Used to mark the vertices and update the priority queue `pq`.
"""
function visit!{T<:Real}(g::AbstractGraph,
                            v::Int,
                            pq::Vector{PrimHeapEntry{T}},
                            distmx::AbstractArray{T, 2},
                            marked::AbstractVector{Bool,1})
    marked[v] = true
    for w in fadj(g, v)
        if !marked[w]
            (ismember, distance) = contains(pq, w)
            if !ismember
                heappush!(pq, PrimHeapEntry(w, Edge(min(v, w), max(v, w)), distmx[v, w]))
            elseif distmx[v, w] < distance
                changeKey!(pq, w, Edge(min(v, w), max(v, w)), distmx[v, w])
            end
        end
    end
end
