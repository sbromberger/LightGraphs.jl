*LightGraphs.jl* implements the following graph operators. In general, functions with two graph arguments will require them to be of the same type (either both `Graph` or both `DiGraph`).

`complement(g)`  
Produces the [graph complement](https://en.wikipedia.org/wiki/Complement_graph) of a graph.

`reverse(g)`  
(`DiGraph` only) Produces a graph where all edges are reversed from the original.

`reverse!(g)`  
(`DiGraph` only) In-place reverse (modifies the original graph).

`union(g, h)`  
Produces a graph with `|V(g)| + |V(h)|` vertices and `|E(g)| + |E(h)|` edges. Put simply, the vertices and edges from graph *h* are appended to graph *g*.

`intersect(g, h)`  
Produces a graph with edges that are only in both graph *g* and graph *h*. Note that this function may produce a graph with 0-degree vertices.

`difference(g, h)`  
Produces a graph with edges in graph *g* that are not in graph *h*. Note that this function may produce a graph with 0-degree vertices.

`symmetric_difference(g, h)`  
Produces a graph with edges from graph *g* that do not exist in graph *h*, and vice versa. Note that this function may produce a graph with 0-degree vertices.

`compose(g, h)`  
Merges graphs *g* and *h* by taking the set union of all vertices and edges.

`function inducedsubgraph(g::AbstractGraph, iter)`
Filter *g* to include only the vertices present in iter which should not have duplicates.
Returns the subgraph of *g* induced by set(iter) along with the mapping from the old vertex names to the new vertex names.

`inducedsubgraph!(h, g, newvid)`
Inplace filtering for preallocated output, edge iterable, vertex mapping.