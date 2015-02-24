*LightGraphs.jl* provides several traversal and shortest-path algorithms. Where appropriate, edge distances may be passed in (by an `edge_dists` keyword argument) as a matrix of `Float` values. The matrix should be indexed by `[src, dst]` (see [Getting Started](gettingstarted.html) for more information).

### Graph Traversal
*Graph traversal* refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements three traversal schemes:
* `BreadthFirst`,
* `DepthFirst`, and
* `MaximumAdjacency`.

During traversal, each vertex maintains a status (also called *color*), which is an integer value defined as below:

* `0`: the vertex has not been encountered (*i.e.* discovered)
* `1`: the vertex has been discovered and remains open
* `2`: the vertex has been closed (*i.e.*, all its neighbors have been examined).

Many graph algorithms can be implemented based on graph traversal through certain *visitors* or by using the colormap in certain ways. For example, in this package, topological sorting, connected components, and cycle detection are all implemented using ``traverse_graph`` with specifically designed visitors.

`traverse_graph(graph, alg, source, visitor[, colormap])`  
Performs a traversal of `graph` using one of the available traversal algorithms, from a `source` vertex using a `visitor` which is an instance of a subtype of type `AbstractGraphVisitor`. Can optionally take a vector of integers that indicates the status of each vertex. If this is not specified, an internal colormap will be used.

In general, `traverse_graph()` will not be called directly, but rather will be used by other specialized functions.

###Cycle Detection
In graph theory, a cycle is defined to be a path that starts from some vertex ``v`` and ends up at ``v``.

`test_cyclic_by_dfs(g)`  
Tests whether a graph contains a cycle through depth-first search. It returns ``true`` when it finds a cycle, otherwise ``false``.

###Simple Minimum Cut
Stoer's simple minimum cut gets the minimum cut of an undirected graph.

`mincut(graph[, edge_dists])`  
Returns a tuple  ``(parity, bestcut)``, where ``parity`` is a vector of boolean values that determines the partition in `graph` and ``bestcut`` is the weight of the cut that makes this partition. An optional edge_dists matrix may be specified; if omitted, edge distances are assumed to be 1.

`maximum_adjacency_visit(graph[, edge_dists]; log, io)`  
Returns the vertices in `graph` traversed by maximum adjacency search. An optional edge_dists matrix may be specified; if omitted, edge distances are assumed to be 1. If `log` (default `false`) is `true`, visitor events will be printed to `io`, which defaults to `STDOUT`; otherwise, no event information will be displayed.


### Shortest-Path Algorithms
#### General properties of shortest path algorithms
*   The distance from a vertex to itself is always `0`.
*   The distance between two vertices with no connecting edge is always `Inf`.


`a_star(g, s, t[, heuristic, edge_dists])`  
Computes the shortest path between vertices *s* and *t* using the [A* search algorithm](http://en.wikipedia.org/wiki/A*_search_algorithm). An optional heuristic function and edge distance matrix may be supplied.

`dijkstra_shortest_paths(g, s[, edge_dists])`  
Performs [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) on a graph, computing shortest distances between a source vertex *s* and all other nodes. Returns a `DijkstraState` that contains various traversal information (see below).

`dijkstra_predecessor_and_distance(g, s[, edge_dists])`  
Performs [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) on a graph similar to `dijkstra_shortest_paths` but returns a `DijkstraStateWithPreds` that keeps track of all predecessors of a given vertex (see below).

`bellman_ford_shortest_paths(g, s[, edge_dists])`  
`bellman_ford_shortest_paths(g, ss[, edge_dists])`  

Uses the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm) to compute shortest paths between a source vertex *s* or a set of source vertices *ss*. Returns a `BellmanFordState` with relevant traversal information (see below).

`floyd_warshall_shortest_paths(g[, edge_dists])`  
`floyd_warshall_shortest_paths(g[, edge_dists])`  

Uses the [Floyd-Warshall algorithm](http://en.wikipedia.org/wiki/Floyd–Warshall_algorithm) to compute shortest paths between all pairs of vertices in graph *g*. Returns a `FloydWarshallState` with relevant traversal information (see below).

Note that this algorithm may return a large amount of data (it will allocate on the order of
*O(nv^2)*).


### Path discovery / enumeration
`enumerate_paths(state[, v])`  
`enumerate_paths(state,[, vs])`  
Given a path state *state* of type `AbstractPathState` (see below), returns a vector (indexed by vertex) of the paths between the source vertex used to compute the path state and a destination vertex *v*, a set of destination vertices *vs*, or the entire graph. For multiple destination vertices, each path is represented by a vector of vertices on the path between the source and the destination. Nonexistent paths will be indicated by an empty vector. For single destinations, the path is represented by a single vector of vertices, and will be length 0 if the path does not exist.

For Floyd-Warshall path states, please note that the output is a bit different, since this
algorithm calculates all shortest paths for all pairs of vertices: `enumerate_paths(state)` will
return a vector (indexed by source vertex) of vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)` will return a vector (indexed by destination vertex) of paths from source *v* to all other vertices. In addition, `enumerate_paths(state, v, d)` will return a vector representing the path from vertex *v* to vertex *d*.

### Path States
The `floyd_warshall_shortest_paths`, `bellman_ford_shortest_paths`, `dijkstra_shortest_paths`, and `dijkstra_predecessor_and_distance` functions return a state that contains various information about the graph learned during traversal. The three state types have the following common information, accessible via the type:

`.dists`  
Holds a vector of distances computed, indexed by source vertex.

`.parents`  
Holds a vector of parents of each source vertex. The parent of a source vertex is always `0`.

In addition, the `dijkstra_predecessor_and_distance` function stores the following information:

`.predecessors`  
Holds a vector, indexed by vertex, of all the predecessors discovered during shortest-path calculations. This keeps track of all parents when there are multiple shortest paths available from the source.

`.pathcounts`  
Holds a vector, indexed by vertex, of the path counts discovered during traversal. This equals the length of each subvector in the `.predecessors` output above.
