"""
    local_clustering_coefficient(g, v)
    local_clustering_coefficient(g, vs)

Return the [local clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient)
for node `v` in graph `g`. If a list of vertices `vs` is specified, return a vector
of coefficients for each node in the list.
"""
function local_clustering_coefficient(g::AbstractGraph, v::Integer)
    ntriang, alltriang = local_clustering(g, v)

    return alltriang == 0 ? 0. : ntriang * 1.0 / alltriang
end
local_clustering_coefficient(g::AbstractGraph, vs = vertices(g)) =
    [local_clustering_coefficient(g, v) for v in vs]


@doc_str """
    local_clustering(g, v)
    local_clustering(g, vs)

Return a tuple `(a, b)`, where `a` is the number of triangles in the neighborhood
of `v` and `b` is the maximum number of possible triangles. If a list of vertices
`vs` is specified, return two vectors representing the number of triangles and
the maximum number of possible triangles, respectively, for each node in the list.

This function is related to the local clustering coefficient `r` by ``r=\frac{a}{b}``.
"""
function local_clustering(g::AbstractGraph, v::Integer)
    k = degree(g, v)
    k <= 1 && return (0, 0)
    neighs = neighbors(g, v)
    c = 0
    for i in neighs, j in neighs
        i == j && continue
        if has_edge(g, i, j)
            c += 1
        end
    end
    return is_directed(g) ? (c , k*(k-1)) : (div(c,2) , div(k*(k-1),2))
end
function local_clustering(g::AbstractGraph, vs = vertices(g))
    ntriang = zeros(Int, length(vs))
    nalltriang = zeros(Int, length(vs))
    i = 0
    for (i, v) in enumerate(vs)
        ntriang[i], nalltriang[i] = local_clustering(g, v)
    end
    return ntriang, nalltriang
end


"""
    triangles(g[, v])
    triangles(g, vs)

Return the number of triangles in the neighborhood of node `v` in graph `g`.
If a list of vertices `vs` is specified, return a vector of number of triangles
for each node in the list. If no vertices are specified, return the number
of triangles for each node in the graph.
"""
triangles(g::AbstractGraph, v::Integer) = local_clustering(g, v)[1]
triangles(g::AbstractGraph, vs = vertices(g)) = local_clustering(g, vs)[1]


"""
    global_clustering_coefficient(g)

Return the [global clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient)
of graph `g`.
"""
function global_clustering_coefficient(g::AbstractGraph)
    c = 0
    ntriangles = 0
    for v in vertices(g)
        neighs = neighbors(g, v)
        for i in neighs, j in neighs
            i == j && continue
            if has_edge(g, i, j)
                c += 1
            end
        end
        k = degree(g, v)
        ntriangles += k*(k-1)
    end
    ntriangles == 0 && return 1.
    return c / ntriangles
end
