"""
    triangle_count(g, alg::TriangleCountAlgorithm)

Return total number of triangles in graph `g` using [`TriangleCountAlgorithm`](@ref)
algorithm `alg`.
"""
function triangle_count end

"""
    abstract type TriangleCountAlgorithm

An abstract type representing an algorithm for finding the total triangle count.
"""
abstract type TriangleCountAlgorithm end

@inline function bsearch(x::T, A::Vector{T}) where T
    n = length(A)
    lo = 0
    hi = n+1
    @inbounds while hi-lo > 1
        m = lo + ((hi - lo) >>> 0x01)
        if A[m] < x
            lo = m
        else
            hi = m
        end
    end
    hi > n && return false
    return A[hi] == x
end

"""
    struct DODG <: TriangleCountAlgorithm

Struct representing an algorithm for finding triangle count in an undirected graph.

### References
- [One Quadrillion Triangles Queried on One Million Processors](https://ieeexplore.ieee.org/document/8916243).
"""
struct DODG <: TriangleCountAlgorithm end

@traitfn function triangle_count(g::AG::(!IsDirected), ::DODG) where {T, AG<:AbstractGraph{T}}
    ntri = UInt64(0)
    deg = degree(g)
    # create a degree-ordered directed graph where the original
    # undirected edges are directed from low-degree to high-degree
    adjlist = [Vector{T}() for _ in vertices(g)]
    @inbounds for u in vertices(g)
        for v in neighbors(g, u)
            # add edge u => v in pruned graph only if degv > degu
            # (or v > u for tie breaking)
            if deg[v] > deg[u] || (deg[v] == deg[u] && v > u)
                push!(adjlist[u], v)
            end
        end
    end
    @inbounds for u in vertices(g)
        adju = adjlist[u]
        lenu = length(adju)
        # chose u as pivot and check all pairs of its neighbors
        for i = 1:lenu
            v = adju[i]
            for j = i+1:lenu
                w = adju[j]
                # for every pair of edges u => v, u => w in the pruned graph
                # if an edge exists between v, w in the original graph we have found
                # a triangle. we check this by searching in the pruned graph instead
                # of the original graph to reduce search space
                wTov = (deg[v] > deg[w] || (deg[v] == deg[w] && v > w))
                if (wTov && bsearch(v, adjlist[w])) ||
                        (!wTov && bsearch(w, adjlist[v]))
                    ntri += 1
                end
            end
        end
    end
    return Float64(ntri)
end

"""
    struct ThreadedDODG <: TriangleCountAlgorithm

Struct representing the multithreaded version of [`DODG`](@ref) algorithm used
to find triangle count in an undirected graph.
"""
struct ThreadedDODG <: TriangleCountAlgorithm end

@traitfn function triangle_count(g::AG::(!IsDirected), ::ThreadedDODG) where {T, AG<:AbstractGraph{T}}
    ntri = zeros(UInt64, nthreads())
    deg = degree(g)
    adjlist = [T[] for _ in vertices(g)]
    partitions = optimal_contiguous_partition(deg, nthreads())
    @threads for u_set in partitions
        @inbounds for u in u_set
            for v in neighbors(g, u)
                if deg[v] > deg[u] || (deg[v] == deg[u] && v > u)
                    push!(adjlist[u], v)
                end
            end
        end
    end
    partitions = optimal_contiguous_partition(map(v -> length(adjlist[v])^2, vertices(g)), nthreads())
    @threads for u_set in partitions
        tid = threadid()
        @inbounds for u in u_set
            adju = adjlist[u]
            lenu = length(adju)
            for i = 1:lenu
                v = adju[i]
                for j = i+1:lenu
                    w = adju[j]
                    wTov = (deg[v] > deg[w] || (deg[v] == deg[w] && v > w))
                    if (wTov && bsearch(v, adjlist[w])) ||
                            (!wTov && bsearch(w, adjlist[v]))
                        ntri[tid] += 1
                    end
                end
            end
        end
    end
    return Float64(sum(ntri))
end

"""
    edge_triangle_count(g, alg::TriangleCountAlgorithm)

Return a Dict mapping every edge to the number of triangles it is part of
in graph `g` using [`TriangleCountAlgorithm`](@ref) algorithm `alg`.
"""

@traitfn function edge_triangle_count(g::AG::(!IsDirected), ::DODG) where {T, AG<:AbstractGraph{T}}
    res = Dict(e => zero(T) for e in edges(g))
    deg = degree(g)
    adjlist = [Vector{T}() for _ in vertices(g)]
    @inbounds for u in vertices(g)
        for v in neighbors(g, u)
            if deg[v] > deg[u] || (deg[v] == deg[u] && v > u)
                push!(adjlist[u], v)
            end
        end
    end
    @inbounds for u in vertices(g)
        adju = adjlist[u]
        lenu = length(adju)
        for i = 1:lenu
            v = adju[i]
            euv = u < v ? SimpleEdge(u, v) : SimpleEdge(v, u)
            euv_tcount = 0
            for j = i+1:lenu
                w = adju[j]
                euw = w < u ? SimpleEdge(w, u) : SimpleEdge(u, w)
                wTov = (deg[v] > deg[w] || (deg[v] == deg[w] && v > w))
                if (wTov && bsearch(v, adjlist[w])) ||
                        (!wTov && bsearch(w, adjlist[v]))
                    evw = w < v ? SimpleEdge(w, v) : SimpleEdge(v, w)
                    res[evw] += 1
                    res[euw] += 1
                    euv_tcount += 1
                end
            end
            res[euv] += euv_tcount
        end
    end
    return res
end

@traitfn function edge_triangle_count(g::AG::(!IsDirected), ::ThreadedDODG) where {T, AG<:AbstractGraph{T}}
    res = Dict(e => Atomic{T}(0) for e in edges(g))
    deg = degree(g)
    adjlist = [T[] for _ in vertices(g)]
    partitions = optimal_contiguous_partition(deg, nthreads())
    @threads for u_set in partitions
        @inbounds for u in u_set
            for v in neighbors(g, u)
                if deg[v] > deg[u] || (deg[v] == deg[u] && v > u)
                    push!(adjlist[u], v)
                end
            end
        end
    end
    partitions = optimal_contiguous_partition(map(v -> length(adjlist[v])^2, vertices(g)), nthreads())
    @threads for u_set in partitions
        tid = threadid()
        @inbounds for u in u_set
            adju = adjlist[u]
            lenu = length(adju)
            for i = 1:lenu
                v = adju[i]
                euv = u < v ? SimpleEdge{T}(u, v) : SimpleEdge{T}(v, u)
                euv_tcount = zero(T)
                for j = i+1:lenu
                    w = adju[j]
                    euw = w < u ? SimpleEdge{T}(w, u) : SimpleEdge{T}(u, w)
                    wTov = (deg[v] > deg[w] || (deg[v] == deg[w] && v > w))
                    if (wTov && bsearch(v, adjlist[w])) ||
                            (!wTov && bsearch(w, adjlist[v]))
                        evw = w < v ? SimpleEdge{T}(w, v) : SimpleEdge{T}(v, w)
                        atomic_add!(res[evw], one(T))
                        atomic_add!(res[euw], one(T))
                        euv_tcount += one(T)
                    end
                end
                atomic_add!(res[euv], euv_tcount)
            end
        end
    end
    return res
end
