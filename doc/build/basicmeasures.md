
<a id='Basic-Functions-1'></a>

# Basic Functions


The following basic measures have been implemented for `Graph` and `DiGraph` types:


<a id='Vertices-and-Edges-1'></a>

## Vertices and Edges

<a id='LightGraphs.vertices' href='#LightGraphs.vertices'>#</a>
**`LightGraphs.vertices`** &mdash; *Function*.



Return the vertices of a graph.

<a id='LightGraphs.edges' href='#LightGraphs.edges'>#</a>
**`LightGraphs.edges`** &mdash; *Function*.



Return an iterator to the edges of a graph. The returned iterator is valid for one pass over the edges, and is invalidated by changes to `g`.

<a id='LightGraphs.is_directed' href='#LightGraphs.is_directed'>#</a>
**`LightGraphs.is_directed`** &mdash; *Function*.



Returns `true` if `g` is a `DiGraph`.

<a id='LightGraphs.nv' href='#LightGraphs.nv'>#</a>
**`LightGraphs.nv`** &mdash; *Function*.



The number of vertices in `g`.

<a id='LightGraphs.ne' href='#LightGraphs.ne'>#</a>
**`LightGraphs.ne`** &mdash; *Function*.



The number of edges in `g`.

<a id='LightGraphs.has_edge' href='#LightGraphs.has_edge'>#</a>
**`LightGraphs.has_edge`** &mdash; *Function*.



Return true if the graph `g` has an edge from `src` to `dst`.

<a id='LightGraphs.has_vertex' href='#LightGraphs.has_vertex'>#</a>
**`LightGraphs.has_vertex`** &mdash; *Function*.



Return true if `v` is a vertex of `g`.

<a id='LightGraphs.in_edges' href='#LightGraphs.in_edges'>#</a>
**`LightGraphs.in_edges`** &mdash; *Function*.



Return an Array of the edges in `g` that arrive at vertex `v`.

<a id='LightGraphs.out_edges' href='#LightGraphs.out_edges'>#</a>
**`LightGraphs.out_edges`** &mdash; *Function*.



Return an Array of the edges in `g` that emanate from vertex `v`.

<a id='LightGraphs.src' href='#LightGraphs.src'>#</a>
**`LightGraphs.src`** &mdash; *Function*.



Return source of an edge.

<a id='LightGraphs.dst' href='#LightGraphs.dst'>#</a>
**`LightGraphs.dst`** &mdash; *Function*.



Return destination of an edge.


<a id='Neighbors-and-Degree-1'></a>

## Neighbors and Degree

<a id='LightGraphs.degree' href='#LightGraphs.degree'>#</a>
**`LightGraphs.degree`** &mdash; *Function*.



Return the number of edges (both ingoing and outgoing) from the vertex `v`.

<a id='LightGraphs.indegree' href='#LightGraphs.indegree'>#</a>
**`LightGraphs.indegree`** &mdash; *Function*.



Return the number of edges which start at vertex `v`.

<a id='LightGraphs.outdegree' href='#LightGraphs.outdegree'>#</a>
**`LightGraphs.outdegree`** &mdash; *Function*.



Return the number of edges which end at vertex `v`.

<a id='LightGraphs.Δ' href='#LightGraphs.Δ'>#</a>
**`LightGraphs.Δ`** &mdash; *Function*.



Return the maximum `degree` of vertices in `g`.

<a id='LightGraphs.δ' href='#LightGraphs.δ'>#</a>
**`LightGraphs.δ`** &mdash; *Function*.



Return the minimum `degree` of vertices in `g`.

<a id='LightGraphs.Δout' href='#LightGraphs.Δout'>#</a>
**`LightGraphs.Δout`** &mdash; *Function*.



Return the maxium `outdegree` of vertices in `g`.

<a id='LightGraphs.δout' href='#LightGraphs.δout'>#</a>
**`LightGraphs.δout`** &mdash; *Function*.



Return the minimum `outdegree` of vertices in `g`.

<a id='LightGraphs.δin' href='#LightGraphs.δin'>#</a>
**`LightGraphs.δin`** &mdash; *Function*.



Return the maximum `indegree` of vertices in `g`.

<a id='LightGraphs.Δin' href='#LightGraphs.Δin'>#</a>
**`LightGraphs.Δin`** &mdash; *Function*.



Return the minimum `indegree` of vertices in `g`.

<a id='LightGraphs.degree_histogram' href='#LightGraphs.degree_histogram'>#</a>
**`LightGraphs.degree_histogram`** &mdash; *Function*.



Produces a histogram of degree values across all vertices for the graph `g`. The number of histogram buckets is based on the number of vertices in `g`. Degree 0 vertices are excluded.

`degree_histogram(g)[i]` is the number of vertices in g with degree `i`.

<a id='LightGraphs.density' href='#LightGraphs.density'>#</a>
**`LightGraphs.density`** &mdash; *Function*.



Density is defined as the ratio of the number of actual edges to the number of possible edges. This is $|v| |v-1|$ for directed graphs and $(|v| |v-1|) / 2$ for undirected graphs.

<a id='LightGraphs.neighbors' href='#LightGraphs.neighbors'>#</a>
**`LightGraphs.neighbors`** &mdash; *Function*.



Returns a list of all neighbors of vertex `v` in `g`.

For DiGraphs, this is equivalent to `out_neighbors(g, v)`.

NOTE: returns a reference, not a copy. Do not modify result.

<a id='LightGraphs.in_neighbors' href='#LightGraphs.in_neighbors'>#</a>
**`LightGraphs.in_neighbors`** &mdash; *Function*.



Returns a list of all neighbors connected to vertex `v` by an incoming edge.

NOTE: returns a reference, not a copy. Do not modify result.

<a id='LightGraphs.all_neighbors' href='#LightGraphs.all_neighbors'>#</a>
**`LightGraphs.all_neighbors`** &mdash; *Function*.



Returns all the vertices which share an edge with `v`.

<a id='LightGraphs.common_neighbors' href='#LightGraphs.common_neighbors'>#</a>
**`LightGraphs.common_neighbors`** &mdash; *Function*.



Returns the neighbors common to vertices `u` and `v` in `g`.

<a id='LightGraphs.neighborhood' href='#LightGraphs.neighborhood'>#</a>
**`LightGraphs.neighborhood`** &mdash; *Function*.



```
neighborhood(g, v::Int, d::Int; dir=:out)
```

Returns a vector of the vertices in `g` at distance less or equal to `d` from `v`. If `g` is a `DiGraph` the `dir` optional argument specifies the edge direction the edge direction with respect to `v` (i.e. `:in` or `:out`) to be considered.
