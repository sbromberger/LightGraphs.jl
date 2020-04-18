"""
    struct Local <: ClusteringScope

A structure representing a local [clustering scope](@ref ClusteringScope).

###Required fields:
- `vs`: a vertex, or vector of vertices, representing the local scope. if `vs` is empty,
  include all vertices in the graph.
"""
struct Local{T} <: ClusteringScope
    vs::T
end

Local() = Local(Vector{UInt8}())

"""
    struct Global <: ClusteringScope

A structure representing a global [clustering scope](@ref ClusteringScope).
"""
struct Global <: ClusteringScope end

"""
    clustering_coefficient(g, scope=Global())

Return the clustering coefficient for graph `g` using [clustering scope](@ref ClusteringScope) `scope`.
For [`Local`](@ref) scopes, return the [local clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient) for the
nodes specified in the scope. For [`Global`](@ref) scopes (the default), return the [global clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(4);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 2, 4);

julia> add_edge!(g, 4, 1);

julia> clustering_coefficient(g, Local([1, 2, 3]))
3-element Array{Float64,1}:
 1.0
 1.0
 0.0

 julia> clustering_coefficient(star_graph(4))
0.0

julia> clustering_coefficient(smallgraph(:housex), Global())
0.7894736842105263
```
"""
function clustering_coefficient(g::AbstractGraph, scope::Local{T}) where {U<:Integer, T<:AbstractVector{U}}
    ntriang, nalltriang = clustering(g, scope)
    return map(p -> p[2] == 0 ? 0. : p[1] * 1.0 / p[2], zip(ntriang, nalltriang))
end

clustering_coefficient(g::AbstractGraph, scope::Local{T}) where {T<:Integer} = clustering_coefficient(g, Local([scope.vs]))[1]

function local_clustering!(storage::AbstractVector{Bool}, g::AbstractGraph, v::Integer)
    k = degree(g, v)
    k <= 1 && return (0, 0)
    neighs = neighbors(g, v)
    tcount = 0
    storage[neighs] .= true

    @inbounds for i in neighs
        i == v && continue
        @inbounds for j in neighbors(g, i)
            if (j != v) && (i != j) && storage[j]
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
    clustering(g, scope::Local)

Return two vectors representing the number of triangles and the maximum number of triangles, respectively,
for each vertex specified in [`Local`](@ref) scope `scope`.

This function is related to the local clustering coefficient `r` by ``r=\\frac{a}{b}``.
"""
function clustering(g::AbstractGraph, scope::Local{T}) where {U<:Integer, T<:AbstractVector{U}}
    vs = isempty(scope.vs) ? vertices(g) : scope.vs
    storage = zeros(Bool, nv(g))
    ntriang = zeros(Int, length(vs))
    nalltriang = zeros(Int, length(vs))
    return local_clustering!(storage, ntriang, nalltriang, g, vs)
end

clustering(g::AbstractGraph, scope::Local{T}) where {T<:Integer} = first.(clustering(g, Local([scope.vs])))

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
triangles(g::AbstractGraph) = clustering(g, Local())[1]
triangles(g::AbstractGraph, v) = clustering(g, Local(v))[1]


function clustering_coefficient(g::AbstractGraph, ::Global)
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

clustering_coefficient(g::AbstractGraph) = clustering_coefficient(g, Global())
