*JuliaGraphs.jl* provides several shortest-path algorithms. Where appropriate, edge distances may be passed in (by an `edge_dists` keyword argument) as a matrix of `Float` values. The matrix should be indexed by `[src, dst]` (see [Getting Started](gettingstarted.html) for more information).

### General properties of shortest path algorithms
*   The distance from a vertex to itself is always `0`.
*   The distance between two vertices with no connecting edge is always `Inf`.

### Shortest-Path Algorithms

`a_star(g, s, t[, heuristic, edge_dists])`  
Computes the shortest path between vertices *s* and *t* using the [A* search algorithm](http://en.wikipedia.org/wiki/A*_search_algorithm). An optional heuristic function and edge distance matrix may be supplied.

`dijkstra_shortest_paths(g, s[, edge_dists])`  
Performs [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) on a graph, computing shortest distances between a source vertex *s* and all other nodes. Returns a `DijkstraState` that contains various traversal information (see below).

`dijkstra_predecessor_and_distance(g, s[, edge_dists])`  
Performs [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) on a graph similar to `dijkstra_shortest_paths` but returns a `DijkstraStateWithPreds` that keeps track of all predecessors of a given vertex (see below).

`bellman_ford_shortest_paths(g, s[, edge_dists])`  
`bellman_ford_shortest_paths(g, ss[, edge_dists])`  

Uses the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm) to compute shortest paths between a source vertex *s* or a set of source vertices *ss*. Returns a `BellmanFordState` with relevant traversal information (see below).

### Path discovery / enumeration
`enumerate_paths(bfs[, d])`  
`enumerate_paths(bfs,[, ds])`  
Given a `BellmanFordState`, returns a vector (indexed by vertex) of the paths between the source vertex *s* used to compute the `BellmanFordState` and a destination vertex, a set of destination vertices, or the entire graph. For multiple destination vertices, each path is represented by a vector of vertices on the path between *s* and the destination. Nonexistent paths will be indicated by an empty vector. For single destinations, the path is represented by a single vector of vertices, and will be length 0 if the path does not exist.

### Algorithm States
The `bellman-ford_shortest_paths`, `dijkstra_shortest_paths`, and `dijkstra_predecessor_and_distance` functions return a state that contains various information about the graph learned during traversal. The three state types have the following common information, accessible via the type:

`.dists`  
Holds a vector of distances computed, indexed by source vertex.

`.parents`  
Holds a vector of parents of each source vertex. The parent of a source vertex is always `0`.

In addition, the `dijkstra_predecessor_and_distance` function stores the following information:

`.predecessors`  
Holds a vector, indexed by vertex, of all the predecessors discovered during shortest-path calculations. This keeps track of all parents when there are multiple shortest paths available from the source.

`.pathcounts`
Holds a vector, indexed by vertex, of the path counts discovered during traversal. This equals the length of each subvector in the `.predecessors` output above.
