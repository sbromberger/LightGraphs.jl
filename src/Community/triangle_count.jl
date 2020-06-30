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

"""
    struct DODG <: TriangleCountAlgorithm

Struct representing an algorithm for finding triangle count in an undirected graph.

### References
- [One Quadrillion Triangles Queried on One Million Processors](https://ieeexplore.ieee.org/document/8916243).
"""
struct DODG <: TriangleCountAlgorithm end

@traitfn function triangle_count(g::AG::(!IsDirected), ::DODG) where {T, AG<:AbstractGraph{T}}
    ntri = 0
    # create a degree-ordered directed graph where the original
    # undirected edges are directed from low-degree to high-degree
    adjlist = [Vector{T}() for _ in vertices(g)]
    @inbounds for u in vertices(g)
        for v in neighbors(g, u)
            degv = degree(g, v)
            degu = degree(g, u)
            # add edge u => v in pruned graph only if degv > degu
            # (or v > u for tie breaking)
            if degv > degu || (degv == degu && v > u)
                push!(adjlist[u], v)
            end
        end
    end
    @inbounds for u in vertices(g)
        adju = adjlist[u]
        lenu = length(adju)
        # chose u as pivot and check all pairs of its neighbors
        for i = 1:lenu, j = i+1:lenu
            v = adju[i]
            w = adju[j]
            # for a pair of edges u => v & u => w, if there is an edge
            # v => w in the original graph then we've found a triangle
            if has_edge(g, v, w)
                ntri += 1
            end
        end
    end
    return ntri
end

"""
    struct ThreadedDODG <: TriangleCountAlgorithm

Struct representing the multithreaded version of [`DODG`](@ref) algorithm used
to find triangle count in an undirected graph.
"""
struct ThreadedDODG <: TriangleCountAlgorithm end

@traitfn function triangle_count(g::AG::(!IsDirected), ::ThreadedDODG) where {T, AG<:AbstractGraph{T}}
    ntri = zeros(Int64, nthreads())
    adjlist = [T[] for _ in vertices(g)]
    partitions = optimal_contiguous_partition(degree(g), nthreads())
    @threads for u_set in partitions
        @inbounds for u in u_set
            for v in neighbors(g, u)
                degv = degree(g, v)
                degu = degree(g, u)
                if degv > degu || (degv == degu && v > u)
                    push!(adjlist[u], v)
                end
            end
        end
    end
    partitions = optimal_contiguous_partition(length.(adjlist), nthreads())
    @threads for u_set in partitions
        tid = threadid()
        @inbounds for u in u_set
            adju = adjlist[u]
            lenu = length(adju)
            for i = 1:lenu, j = i+1:lenu
                v = adju[i]
                w = adju[j]
                if has_edge(g, v, w)
                    ntri[tid] += 1
                end
            end
        end
    end
    return sum(ntri)
end
