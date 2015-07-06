*LightGraphs.jl* provides several traversal and shortest-path algorithms, along with
various utility functions. Where appropriate, edge distances may be passed in as a
matrix of real number values. The matrix should be indexed by `[src, dst]` (see [Getting Started](gettingstarted.html) for more information).

### Graph Traversal
*Graph traversal* refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements three traversal schemes:
* `BreadthFirst`,
* `DepthFirst`, and
* `MaximumAdjacency`.

`bfs_tree(g)`, `dfs_tree(g)`
Provides a breadth-first or depth-first traversal of the graph ``g`` , and returns a directed
acyclic graph of vertices in the order they were discovered.


### Connectivity / Bipartiteness
*Graph connectivity* functions are defined on both undirected and directed graphs:

`connected components(g)`
Will return the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of an undirected graph ``g`` as a vector of components, each represented by a vector
of vectors of vertices belonging to the component.

`strongly_connected_components(g)`, `weakly_connected_components(g)`
For directed graphs, both strong and weak connectivity are supported.

`is_bipartite(g)`   
Will return ``true`` if graph ``g`` is [bipartite](https://en.wikipedia.org/wiki/Bipartite_graph).

###Cycle Detection
In graph theory, a cycle is defined to be a path that starts from some vertex ``v`` and ends up at ``v``.

`is_cyclic(g)`  
Tests whether a graph contains a cycle through depth-first search. It returns ``true`` when it finds a cycle, otherwise ``false``.

###Simple Minimum Cut
Stoer's simple minimum cut gets the minimum cut of an undirected graph.

`mincut(graph[, distmx])`  
Returns a tuple  ``(parity, bestcut)``, where ``parity`` is a vector of boolean values that determines the partition in `graph` and ``bestcut`` is the weight of the cut that makes this partition. An optional distmx matrix may be specified; if omitted, edge distances are assumed to be 1.

`maximum_adjacency_visit(graph[, distmx]; log, io)`  
Returns the vertices in `graph` traversed by maximum adjacency search. An optional distmx matrix may be specified; if omitted, edge distances are assumed to be 1. If `log` (default `false`) is `true`, visitor events will be printed to `io`, which defaults to `STDOUT`; otherwise, no event information will be displayed.


### Shortest-Path Algorithms
#### General properties of shortest path algorithms
*   The distance from a vertex to itself is always `0`.
*   The distance between two vertices with no connecting edge is always `Inf`.


`a_star(g, s, t[, heuristic, distmx])`  
Computes the shortest path between vertices *s* and *t* using the [A* search algorithm](http://en.wikipedia.org/wiki/A*_search_algorithm). An optional heuristic function and edge distance matrix may be supplied.

`dijkstra_shortest_paths(g, s[, distmx; allpaths=false])`  
Performs [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) on a graph, computing shortest distances between a source vertex *s* and all other nodes. Returns a `DijkstraState` that contains various traversal information (see below).

With `allpaths=true`, returns a `DijkstraState` that keeps track of all predecessors of a given vertex (see below).

`bellman_ford_shortest_paths(g, s[, distmx])`  
`bellman_ford_shortest_paths(g, ss[, distmx])`  

Uses the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm) to compute shortest paths between a source vertex *s* or a set of source vertices *ss*. Returns a `BellmanFordState` with relevant traversal information (see below).

`floyd_warshall_shortest_paths(g[, distmx])`  
`floyd_warshall_shortest_paths(g[, distmx])`  

Uses the [Floyd-Warshall algorithm](http://en.wikipedia.org/wiki/Floyd–Warshall_algorithm) to compute shortest paths between all pairs of vertices in graph *g*. Returns a `FloydWarshallState` with relevant traversal information (see below).

Note that this algorithm may return a large amount of data (it will allocate on the order of
*O(nv^2)*).


### Path discovery / enumeration

`gdistances(g, s)`, `gdistances!(g, s, dists)`, `gdistances!(g, s; defaultdist)`
Returns the geodesic distances of graph ``g``. Sources ``s`` can be an integer representing
a vertex, or a vector of integers representing vertices, in ``g``.

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
