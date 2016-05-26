
<a id='Community-Structures-1'></a>

# Community Structures


*LightGraphs.jl* contains many algorithm to detect and analyze community structures in graphs.


<a id='clustering-coefficients-1'></a>

## clustering coefficients

<a id='LightGraphs.local_clustering_coefficient' href='#LightGraphs.local_clustering_coefficient'>#</a>
**`LightGraphs.local_clustering_coefficient`** &mdash; *Function*.



```
local_clustering_coefficient(g, vlist = vertices(g))
```

Returns a vector containing  the [local clustering coefficients](https://en.wikipedia.org/wiki/Clustering_coefficient) for vertices `vlist`.

```
local_clustering_coefficient(g, v)
```

Computes the [local clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient) for node `v`.

<a id='LightGraphs.local_clustering' href='#LightGraphs.local_clustering'>#</a>
**`LightGraphs.local_clustering`** &mdash; *Function*.



```
local_clustering(g, vlist = vertices(g))
```

Returns two vectors, respectively containing  the first and second result of `local_clustering_coefficients(g, v)` for each `v` in `vlist`.

```
local_clustering(g, v)
```

Returns a tuple `(a,b)`, where `a` is the number of triangles in the neighborhood of `v` and `b` is the maximum number of possible triangles. It is related to the local clustering coefficient  by `r=a/b`.

<a id='LightGraphs.global_clustering_coefficient' href='#LightGraphs.global_clustering_coefficient'>#</a>
**`LightGraphs.global_clustering_coefficient`** &mdash; *Function*.



```
global_clustering_coefficient(g)
```

Computes the [global clustering coefficient](https://en.wikipedia.org/wiki/Clustering_coefficient).


<a id='modularity-1'></a>

## modularity

<a id='LightGraphs.modularity' href='#LightGraphs.modularity'>#</a>
**`LightGraphs.modularity`** &mdash; *Function*.



```
modularity(g, c)
```

Computes Newman's modularity `Q` for graph `g` given the partitioning `c`.


<a id='community-detection-1'></a>

## community detection

<a id='LightGraphs.community_detection_nback' href='#LightGraphs.community_detection_nback'>#</a>
**`LightGraphs.community_detection_nback`** &mdash; *Function*.



```
community_detection_nback(g, k::Int)
```

Community detection using the spectral properties of the non-backtracking matrix of `g` (see [Krzakala et al.](http://www.pnas.org/content/110/52/20935.short)).

`g`: imput Graph `k`: number of communities to detect

return : array containing vertex assignments


<a id='core-periphery-1'></a>

## core-periphery

<a id='LightGraphs.core_periphery_deg' href='#LightGraphs.core_periphery_deg'>#</a>
**`LightGraphs.core_periphery_deg`** &mdash; *Function*.



```
core_periphery_deg(g)
```

A simple degree-based core-periphery detection algorithm (see [Lip](http://arxiv.org/abs/1102.5511)). Returns the vertex assignments (1 for core and 2 for periphery).


<a id='cliques-1'></a>

## cliques


*LightGraphs.jl* implements maximal clique discovery using

<a id='LightGraphs.maximal_cliques' href='#LightGraphs.maximal_cliques'>#</a>
**`LightGraphs.maximal_cliques`** &mdash; *Function*.



Finds all maximal cliques of an undirected graph.

```
julia> using LightGraphs
julia> g = Graph(3)
julia> add_edge!(g, 1, 2)
julia> add_edge!(g, 2, 3)
julia> maximal_cliques(g)
2-element Array{Array{Int64,N},1}:
 [2,3]
 [2,1]
```

