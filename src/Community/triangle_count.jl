"""
    triangle_count(g)

Return total number of triangles in the undirected graph `g`.

### References
- [One Quadrillion Triangles Queried on One Million Processors](https://ieeexplore.ieee.org/document/8916243).
"""
@traitfn function triangle_count(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}}
    ntri = 0
    # create a degree-ordered directed graph where the original
    # undirected edges are directed from low-degree to high-degree
    adjlist = [T[] for _ in vertices(g)]
    for u in vertices(g)
        for v in neighbors(g, u)
            degv = degree(g, v)
            degu = degree(g, u)
            # only add edge u => v in new graph only if degv > degu
            # (or v > u for tie breaking)
            if degv > degu || (degv == degu && v > u)
                push!(adjlist[u], v)
            end
        end
    end
    for u in vertices(g)
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
    ThreadedTriangleCount

Struct representing a multithreaded algorithm for triangle count
"""
struct ThreadedTriangleCount end

@traitfn function triangle_count(g::AG::(!IsDirected), ::ThreadedTriangleCount) where {T, AG<:AbstractGraph{T}}
    ntri = zeros(Int64, nthreads())
    adjlist = [T[] for _ in vertices(g)]
    partitions = optimal_contiguous_partition(degree(g), nthreads())
    @threads for u_set in partitions
        for u in u_set
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
        for u in u_set
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
