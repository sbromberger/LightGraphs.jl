"""
    local_clustering_coefficient(g, v)

Computes the [local clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient) for node `v`.
"""
function local_clustering_coefficient(g::AbstractGraph, v::Integer)
    ntriang, alltriang = local_clustering(g, v)

    return alltriang == 0 ? 0. : ntriang / alltriang
end

"""
    local_clustering(g, v)

Returns a tuple `(a,b)`, where `a` is the number of triangles in the neighborhood of
`v` and `b` is the maximum number of possible triangles.
It is related to the local clustering coefficient  by `r=a/b`.
"""
function local_clustering(g::AbstractGraph, v::Integer)
    k = degree(g, v)
    k <= 1 && return (0, 0)
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
    return is_directed(g) ? (c , k*(k-1)) : (div(c,2) , div(k*(k-1),2))
end

"""
    triangles(g, v)

Returns the number of triangles in the neighborhood for node `v`.
"""
triangles(g::AbstractGraph, v::Integer) = local_clustering(g, v)[1]


"""
    local_clustering_coefficient(g, vlist = vertices(g))

Returns a vector containing  the [local clustering coefficients](https://en.wikipedia.org/wiki/Clustering_coefficient) for vertices `vlist`.
"""
local_clustering_coefficient(g::AbstractGraph, vlist = vertices(g)) = Float64[local_clustering_coefficient(g, v) for v in vlist]

"""
    local_clustering(g, vlist = vertices(g))

Returns two vectors, respectively containing  the first and second result of `local_clustering_coefficients(g, v)`
for each `v` in `vlist`.
"""
function local_clustering(g::AbstractGraph, vlist = vertices(g))
    ntriang = zeros(Int, length(vlist))
    nalltriang = zeros(Int, length(vlist))
    i = 0
    for v in vlist
        i+=1
        ntriang[i], nalltriang[i] = local_clustering(g, v)
    end
    return ntriang, nalltriang
end

"""
    triangles(g, vlist = vertices(g))

Returns a vector containing the number of triangles for vertices `vlist`.
"""
triangles(g::AbstractGraph, vlist = vertices(g)) = local_clustering(g, vlist)[1]


"""
    global_clustering_coefficient(g)

Computes the [global clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient).
"""
function global_clustering_coefficient(g::AbstractGraph)
    c = 0
    ntriangles = 0
    for v in vertices(g)
        neighs = neighbors(g, v)
        for i=1:length(neighs), j=1:length(neighs)
            i == j && continue
            if has_edge(g, neighs[i], neighs[j])
                c += 1
            end
        end
        k = degree(g, v)
        ntriangles += k*(k-1)
    end
    ntriangles == 0 && return 1.
    return c / ntriangles
end
