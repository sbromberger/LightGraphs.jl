"""
    local_clustering_coefficient(g, v)
    local_clustering_coefficient(g, vs)

Return the [local clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient)
for node `v` in graph `g`. If a list of vertices `vs` is specified, return a vector
of coefficients for each node in the list.
"""
function local_clustering_coefficient(g::AbstractGraph, v::Integer)
    ntriang, nalltriang = local_clustering(g, v)
    return nalltriang == 0 ? 0. : ntriang * 1.0 / nalltriang
end

function local_clustering_coefficient(g::AbstractGraph, vs = vertices(g))
    ntriang, nalltriang = local_clustering(g, vs)
    return map(p->p[2]==0? 0. : p[1]*1.0/p[2], zip(ntriang, nalltriang))
end


function local_clustering!(storage::AbstractVector{Bool}, g::AbstractGraph, v::Integer)
    k = degree(g, v)
    k <= 1 && return (0, 0)
    neighs = neighbors(g, v)
    tcount = 0
    for i in neighs
        storage[i] = true
    end
    for i in neighs
        for j in neighbors(g, i)
            i == j && continue
            if storage[j]
                tcount += 1
            end
        end
    end
    return is_directed(g) ? (tcount , k*(k-1)) : (div(tcount,2) , div(k*(k-1),2))
end

function local_clustering!(storage::AbstractVector{Bool},
                           ntriang::AbstractVector{Int},
                           nalltriang::AbstractVector{Int},
                           g::AbstractGraph,
                           vs)
    i = 0
    for (i, v) in enumerate(vs)
        ntriang[i], nalltriang[i] = local_clustering!(storage, g, v)
        for w in neighbors(g, v)
            storage[w] = false
        end
    end
    return ntriang, nalltriang
end

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
    storage = zeros(Bool, nv(g))
    return local_clustering!(storage, g, v)
end

function local_clustering(g::AbstractGraph, vs = vertices(g))
    storage = zeros(Bool, nv(g))
    ntriang = zeros(Int, length(vs))
    nalltriang = zeros(Int, length(vs))
    return local_clustering!(storage, ntriang, nalltriang, g, vs)
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
