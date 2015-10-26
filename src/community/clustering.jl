"""
Computes the [local clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient) for node `v`.
"""
function local_clustering(g::SimpleGraph, v::Int)
    k = degree(g, v)
    k <= 1 && return 1.
    neighs = neighbors(g, v)
    c = 0
    for i=1:length(neighs)
        for j=1:length(neighs)
            i == j && continue
            if has_edge(g, neighs[i], neighs[j])
                c += 1
            end
        end
    end
    return c / (k*(k-1))
end

"""
Returns a vector containing  the [local clustering coefficients](https://en.wikipedia.org/wiki/Clustering_coefficient) for vertices `v`.
"""
local_clustering(g::SimpleGraph, v = vertices(g)) = Float64[local_clustering(g, v) for v in v]

"""
Computes the [global clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient).
"""
function global_clustering(g::SimpleGraph)
    c = 0
    ntriangles = 0
    for v in 1:nv(g)
        neighs = neighbors(g, v)
        for i=1:length(neighs)
            for j=1:length(neighs)
                i == j && continue
                if has_edge(g, neighs[i], neighs[j])
                    c += 1
                end
            end
        end
        k = degree(g, v)
        ntriangles += k*(k-1)
    end
    ntriangles == 0 && return 1.
    return c / ntriangles
end
