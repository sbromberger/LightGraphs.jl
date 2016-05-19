
<a id='Centrality-Measures-1'></a>

# Centrality Measures


[Centrality measures](https://en.wikipedia.org/wiki/Centrality) describe the importance of a vertex to the rest of the graph using some set of criteria. Centrality measures implemented in *LightGraphs.jl* include the following:

<a id='LightGraphs.degree_centrality' href='#LightGraphs.degree_centrality'>#</a>
**`LightGraphs.degree_centrality`** &mdash; *Function*.



Calculates the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality) of the graph `g`, with optional (default) normalization.

<a id='LightGraphs.indegree_centrality' href='#LightGraphs.indegree_centrality'>#</a>
**`LightGraphs.indegree_centrality`** &mdash; *Function*.



Calculates the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality) of the graph `g`, with optional (default) normalization.

<a id='LightGraphs.outdegree_centrality' href='#LightGraphs.outdegree_centrality'>#</a>
**`LightGraphs.outdegree_centrality`** &mdash; *Function*.



Calculates the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality) of the graph `g`, with optional (default) normalization.

<a id='LightGraphs.closeness_centrality' href='#LightGraphs.closeness_centrality'>#</a>
**`LightGraphs.closeness_centrality`** &mdash; *Function*.



Calculates the [closeness centrality](https://en.wikipedia.org/wiki/Centrality#Closeness_centrality) of the graph `g`.

<a id='LightGraphs.betweenness_centrality' href='#LightGraphs.betweenness_centrality'>#</a>
**`LightGraphs.betweenness_centrality`** &mdash; *Function*.



```
betweenness_centrality(g, k=0; normalize=true, endpoints=false)
```

Calculates the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) of the graph `g`, or, optionally, of a random subset of `k` vertices. Can optionally include endpoints in the calculations. Normalization is enabled by default.

Betweenness centrality is defined as:

$bc(v) = \frac{1}{\mathcal{N}} \sum_{s \neq t \neq v}
        \frac{\sigma_{st}(v)}{\sigma_{st}}$
.

**Parameters**

g: SimpleGraph     A Graph, directed or undirected.

k: Integer, optional     Use `k` nodes sample to estimate the betweenness centrality. If none,     betweenness centrality is computed using the `n` nodes in the graph.

normalize: bool, optional     If true, the betweenness values are normalized by the total number     of possible distinct paths between all pairs in the graphs. For an undirected graph,     this number if `((n-1)*(n-2))/2` and for a directed graph, `(n-1)*(n-2)`     where `n` is the number of nodes in the graph.

endpoints: bool, optional     If true, endpoints are included in the shortest path count.

**Returns**

betweenness: Array{Float64}     Betweenness centrality value per node id.

**References**

[1] Brandes 2001 & Brandes 2008

<a id='LightGraphs.katz_centrality' href='#LightGraphs.katz_centrality'>#</a>
**`LightGraphs.katz_centrality`** &mdash; *Function*.



Calculates the [Katz centrality](https://en.wikipedia.org/wiki/Katz_centrality) of the graph `g`.

<a id='LightGraphs.pagerank' href='#LightGraphs.pagerank'>#</a>
**`LightGraphs.pagerank`** &mdash; *Function*.



Calculates the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the graph `g`. Can optionally specify a different damping factor (`α`), number of iterations (`n`), and convergence threshold (`ϵ`). If convergence is not reached within `n` iterations, an error will be returned.

