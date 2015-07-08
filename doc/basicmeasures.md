The following basic measures have been implemented for `Graph` and `DiGraph`
types:

### Vertices and Edges

`vertices(g)`  
Returns an iterable (`UnitRange`) representing the vertices in `g`.

`edges(g)`  
Returns the set of edges in `g`.

`==(g, h)`  
Returns true if `vertices(g) == vertices(h)` and `edges(g) == edges(h)`.

`is_directed(g)`  
Returns true if `g` is a `DiGraph`.

`nv(g)`, `ne(g)`  
Returns the number of vertices (order) and edges (size), respectively, in `g`.

`has_edge(g, e)`  
`has_edge(g, src, dst)`  
Returns true if the edge represeted by `e` or by `src, dst` exists in `g`.

`has_vertex(g, v)`  
Returns true if the vertex `v` exists in `g`.

`in_edges(g, v)`  
`out_edges(g, v)`  
Returns the edges with vertex `v` as a destination or as a source.

`src(e)`  
`dst(e)`  
Returns the source or destination vertex of edge `e`.

`reverse(e)`  
Returns an edge whose source and destination are switched from edge `e`.

`==(e, f)`  
Will return true if edges `e` and `f` have the same source and destination
vertices.

### Neighbors and Degree

`degree(g, v)`  
`indegree(g, v)`  
`outdegree(g, v)`  
Returns the degree (indegree, outdegree) of vertex `v` in `g`.

`Δ(g)`  
`δ(g)`  
Returns the maximum (minimum) degree of `g` across all vertices.

`Δout(g)`  
`δout(g)`  
Returns the maximum (minimum) outdegree of `g` across all vertices.

`δin(g)`  
`Δin(g)`  
Returns the maximum (minimum) indegree of `g` across all vertices.

`degree_histogram(g)`  
Produces a histogram of degree values across all vertices for the graph `g`.
The number of histogram buckets is based on the number of vertices in `g`.

`density(g)`  
Returns the density of graph `g`. Density is defined as the ratio of the number
of actual edges to the number of possible edges (`(|v| |v-1|)` for directed
graphs, `(|v| |v-1|) / 2` for undirected graphs).

`neighbors(g, v)`  
Returns a list of all neighbors of vertex `v` in `g`. For DiGraphs, this is
equivalent to `out_neighbors(g, v)`, below.

`in_neighbors(g, v)`  
`out_neighbors(g, v)`  
Returns a list of all neighbors connected to vertex `v` by an outgoing
(incoming) edge.

`all_neighbors(g, v)`
(Digraph only): Returns a list of all (unique) inbound and outbound neighbors.

`common_neighbors(g, u, v)`  
Returns the neighbors common to vertices `u` and `v` in `g`.
