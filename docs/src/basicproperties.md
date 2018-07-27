# Accessing Graph Properties
The following is an overview of functions for accessing graph properties. For functions that modify graphs, see [Making and Modifying Graphs](@ref).

## Graph Properties:

- `nv`: Returns number of vertices in graph.
- `ne`: Returns number of edges in graph.
- `vertices`: Iterable object of all graph vertices.
- `edges`: Iterable object of all graph edges.
- `has_vertex`: Checks for whether graph includes a vertex.
- `has_edge(g, s, d)`: Checks for whether graph includes an edge from a given source `s` to a given destination `d`.
-  `has_edge(g, e)` will return true if there is an edge in g that satisfies `e == f` for any `f ∈ edges(g)`. This is a strict equality test that may not limit itself for testing that just there exists any edge between the source and destination.
Note: to use the `has_edge(g, e)` method safely, it is important to understand the conditions under which edges are equal to each other. These conditions are defined by the `has_edge(g::G,e)` method **as defined** by the `G` graph type. The default behavior is to check `has_edge(g,src(e),dst(e))`.
- `has_self_loops` Checks for self-loops.
- `is_directed` Checks if graph is directed.
- `eltype` Returns element type of graphs.

## Vertex Properties

- `neighbors`: Return array of neighbors of a vertex. If graph is directed, output is equivalent of `outneighbors`.
- `all_neighbors`:  Returns array of all neighbors (both `inneighbors` and `outneighbors`). For undirected graphs, equivalent to `neighbors`.
- `inneighbors`: Return array of in-neighbors. Equivalent to `neighbors` for undirected graphs.
- `outneighbors`: Return array of out-neighbors. Equivalent to `neighbors` for undirected graphs.

## Edge Properties

- `src`: Give source vertex of an edge.
- `dst`: Give destination vertex of an edge.
- `reverse`: Creates a new edge running in opposite direction of passed edge.
