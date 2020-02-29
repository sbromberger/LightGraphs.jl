#Helper function used due to performance bug in @threads. 
function _loopbody!(
    pivot::U, 
    nvg::U,
    dists::Matrix{T}, 
    parents::Matrix{U}
    ) where T<:Real where U<:Integer
    # Relax dists[u, v] = min(dists[u, v], dists[u, pivot]+dists[pivot, v]) for all u, v
    @inbounds @threads for v in one(U):nvg
        d = dists[pivot, v]
        if d != typemax(T) && v != pivot
            p = parents[pivot, v]
            @inbounds for u in one(U):nvg
                ans = (dists[u, pivot] == typemax(T) || u == pivot ? typemax(T) : dists[u, pivot] + d) 
                if dists[u, v] > ans
                    dists[u, v] = ans
                    parents[u, v] = p
                end
            end
        end
    end
end

function parallel_shortest_paths(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T}, ::FloydWarshall
) where T<:Real where U<:Integer
    nvg = nv(g)
    dists = fill(typemax(T), (Int(nvg), Int(nvg)))
    parents = zeros(U, (Int(nvg), Int(nvg)))

    for v in 1:nvg
        dists[v, v] = zero(T)
    end
    undirected = !is_directed(g)
    for e in edges(g)
        u = src(e)
        v = dst(e)

        d = distmx[u, v]

        dists[u, v] = min(d, dists[u, v])
        parents[u, v] = u
        if undirected
            dists[v, u] = min(d, dists[v, u])
            parents[v, u] = v
        end
    end

    for pivot in vertices(g)
        _loopbody!(pivot, nvg, dists, parents) #Due to bug in @threads
    end
    fws = FloydWarshallResults(dists, parents)
    return fws
end

parallel_shortest_paths(g::AbstractGraph, ds::FloydWarshall) = parallel_shortest_paths(g, weights(g), ds)
