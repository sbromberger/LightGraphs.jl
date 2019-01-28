"""
    local_clustering_coefficient(g, v)
    local_clustering_coefficient(g, vs)

Return the [local clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient)
for node `v` in graph `g`. If a list of vertices `vs` is specified, return a vector
of coefficients for each node in the list.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(4);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 2, 4);

julia> add_edge!(g, 4, 1);

julia> local_clustering_coefficient(g, [1, 2, 3])
3-element Array{Float64,1}:
 1.0
 1.0
 0.0
```
"""
function local_clustering_coefficient(g::AbstractGraph, v::Integer)
    ntriang, nalltriang = local_clustering(g, v)
    return nalltriang == 0 ? 0. : ntriang * 1.0 / nalltriang
end

function local_clustering_coefficient(g::AbstractGraph, vs = vertices(g))
    ntriang, nalltriang = local_clustering(g, vs)
    return map(p -> p[2] == 0 ? 0. : p[1] * 1.0 / p[2], zip(ntriang, nalltriang))
end

function local_clustering!(storage::AbstractVector{Bool}, g::AbstractGraph, v::Integer)
    k = degree(g, v)
    k <= 1 && return (0, 0)
    neighs = neighbors(g, v)
    tcount = 0
    storage[neighs] .= true

    @inbounds for i in neighs
        @inbounds for j in neighbors(g, i)
            if (i != j) && storage[j]
                tcount += 1
            end
        end
    end
    return is_directed(g) ? (tcount, k * (k - 1)) : (div(tcount, 2), div(k * (k - 1), 2))
end

function local_clustering!(storage::AbstractVector{Bool},
                           ntriang::AbstractVector{Int},
                           nalltriang::AbstractVector{Int},
                           g::AbstractGraph,
                           vs)
    i = 0
    for (i, v) in enumerate(vs)
        ntriang[i], nalltriang[i] = local_clustering!(storage, g, v)
        storage[neighbors(g, v)] .= false
    end
    return ntriang, nalltriang
end

"""
    local_clustering(g, v)
    local_clustering(g, vs)

Return a tuple `(a, b)`, where `a` is the number of triangles in the neighborhood
of `v` and `b` is the maximum number of possible triangles. If a list of vertices
`vs` is specified, return two vectors representing the number of triangles and
the maximum number of possible triangles, respectively, for each node in the list.

This function is related to the local clustering coefficient `r` by ``r=\\frac{a}{b}``.
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

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(4);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 2, 4);

julia> add_edge!(g, 4, 1);

julia> triangles(g)
4-element Array{Int64,1}:
 1
 1
 0
 1
```
"""
triangles(g::AbstractGraph, v::Integer) = local_clustering(g, v)[1]
triangles(g::AbstractGraph, vs = vertices(g)) = local_clustering(g, vs)[1]


"""
    global_clustering_coefficient(g)

Return the [global clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient)
of graph `g`.

# Examples
```jldoctest
julia> using LightGraphs

julia> global_clustering_coefficient(StarGraph(4))
0.0

julia> global_clustering_coefficient(smallgraph(:housex))
0.7894736842105263
```
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
        ntriangles += k * (k - 1)
    end
    ntriangles == 0 && return 1.
    return c / ntriangles
end

"""
    triangle_count(g::AbstractGraph)

Returns the total number of triangles in a graph
"""
function triangle_count end

@traitfn function triangle_count(g::::(!IsDirected))
    ntriangles = 0
    for u in vertices(g)
        u_nbrs = outneighbors(g, u)
        for i in 1:length(u_nbrs)
            v = u_nbrs[i]
            compare_degree(g, u, v) || continue
            for j in i+1:length(u_nbrs)
                w = u_nbrs[j]
                compare_degree(g, u, w) || continue
                if has_edge(g, v, w)
                    ntriangles += 1
                end
            end
        end
    end
    return ntriangles
end

@traitfn function triangle_count(g::::IsDirected)
    ntriangles = 0
    for u in vertices(g)
        for v in outneighbors(g, u)
            for w in outneighbors(g, v)
                if has_edge(g, w, u)
                    ntriangles += 1
                end
            end
        end
    end
    return ntriangles ÷ 3
end

function compare_degree(g, u, v)
    if (degree(g, u) < degree(g, v)) || (degree(g, u) == degree(g, u) && u < v)
        return true
    end
    return false
end
