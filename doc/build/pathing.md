
<a id='Path-and-Traversal-1'></a>

# Path and Traversal


*LightGraphs.jl* provides several traversal and shortest-path algorithms, along with various utility functions. Where appropriate, edge distances may be passed in as a matrix of real number values.


Edge distances for most traversals may be passed in as a sparse or dense matrix of  values, indexed by `[src,dst]` vertices. That is, `distmx[2,4] = 2.5` assigns the distance `2.5` to the (directed) edge connecting vertex 2 and vertex 4. Note that also for undirected graphs `distmx[4,2]` has to be set.


Any graph traversal  will traverse an edge only if it is present in the graph. When a distance matrix is passed in,


1. distance values for undefined edges will be ignored, and
2. any unassigned values (in sparse distance matrices), for edges that are present in the graph, will be assumed to take the default value of 1.0.
3. any zero values (in sparse/dense distance matrices), for edges that are present in the graph, will instead have an implicit edge cost of 1.0.


<a id='Graph-Traversal-1'></a>

## Graph Traversal


*Graph traversal* refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements three traversal schemes:


  * `BreadthFirst`,
  * `DepthFirst`, and
  * `MaximumAdjacency`.

<a id='LightGraphs.bfs_tree' href='#LightGraphs.bfs_tree'>#</a>
**`LightGraphs.bfs_tree`** &mdash; *Function*.



Provides a breadth-first traversal of the graph `g` starting with source vertex `s`, and returns a directed acyclic graph of vertices in the order they were discovered.

This function is a high level wrapper around bfs_tree!, use that function for more performance.

<a id='LightGraphs.dfs_tree' href='#LightGraphs.dfs_tree'>#</a>
**`LightGraphs.dfs_tree`** &mdash; *Function*.



```
dfs_tree(g, s::Int)
```

Provides a depth-first traversal of the graph `g` starting with source vertex `s`, and returns a directed acyclic graph of vertices in the order they were discovered.

<a id='LightGraphs.maximum_adjacency_visit' href='#LightGraphs.maximum_adjacency_visit'>#</a>
**`LightGraphs.maximum_adjacency_visit`** &mdash; *Function*.



Returns the vertices in `g` traversed by maximum adjacency search. An optional `distmx` matrix may be specified; if omitted, edge distances are assumed to be 1. If `log` (default `false`) is `true`, visitor events will be printed to `io`, which defaults to `STDOUT`; otherwise, no event information will be displayed.


<a id='Random-walks-1'></a>

## Random walks


*LightGraphs* includes uniform random walks and self avoiding walks:

<a id='LightGraphs.randomwalk' href='#LightGraphs.randomwalk'>#</a>
**`LightGraphs.randomwalk`** &mdash; *Function*.



Performs a random walk on graph `g` starting at vertex `s` and continuing for a maximum of `niter` steps. Returns a vector of vertices visited in order.

<a id='LightGraphs.saw' href='#LightGraphs.saw'>#</a>
**`LightGraphs.saw`** &mdash; *Function*.



Performs a [self-avoiding walk](https://en.wikipedia.org/wiki/Self-avoiding_walk) on graph `g` starting at vertex `s` and continuing for a maximum of `niter` steps. Returns a vector of vertices visited in order.


<a id='Connectivity-/-Bipartiteness-1'></a>

## Connectivity / Bipartiteness


`Graph connectivity` functions are defined on both undirected and directed graphs:

<a id='LightGraphs.is_connected' href='#LightGraphs.is_connected'>#</a>
**`LightGraphs.is_connected`** &mdash; *Function*.



```
is_connected(g)
```

Returns `true` if `g` is connected. For DiGraphs, this is equivalent to a test of weak connectivity.

<a id='LightGraphs.is_strongly_connected' href='#LightGraphs.is_strongly_connected'>#</a>
**`LightGraphs.is_strongly_connected`** &mdash; *Function*.



Returns `true` if `g` is (strongly) connected.

<a id='LightGraphs.is_weakly_connected' href='#LightGraphs.is_weakly_connected'>#</a>
**`LightGraphs.is_weakly_connected`** &mdash; *Function*.



Returns `true` if the undirected graph of `g` is connected.

<a id='LightGraphs.connected_components' href='#LightGraphs.connected_components'>#</a>
**`LightGraphs.connected_components`** &mdash; *Function*.



```
connected_components(g)
```

Returns the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory)) of `g` as a vector of components, each represented by a vector of vertices belonging to the component.

<a id='LightGraphs.strongly_connected_components' href='#LightGraphs.strongly_connected_components'>#</a>
**`LightGraphs.strongly_connected_components`** &mdash; *Function*.



Computes the (strongly) connected components of a directed graph.

<a id='LightGraphs.weakly_connected_components' href='#LightGraphs.weakly_connected_components'>#</a>
**`LightGraphs.weakly_connected_components`** &mdash; *Function*.



Returns connected components of the undirected graph of `g`.

<a id='LightGraphs.has_self_loop' href='#LightGraphs.has_self_loop'>#</a>
**`LightGraphs.has_self_loop`** &mdash; *Function*.



Returns true if `g` has any self loops.

<a id='LightGraphs.attracting_components' href='#LightGraphs.attracting_components'>#</a>
**`LightGraphs.attracting_components`** &mdash; *Function*.



Returns a vector of vectors of integers representing lists of attracting components in `g`. The attracting components are a subset of the strongly connected components in which the components do not have any leaving edges.

<a id='LightGraphs.is_bipartite' href='#LightGraphs.is_bipartite'>#</a>
**`LightGraphs.is_bipartite`** &mdash; *Function*.



```
is_bipartite(g)
is_bipartite(g, v)
```

Will return `true` if graph `g` is [bipartite](https://en.wikipedia.org/wiki/Bipartite_graph). If a node `v` is specified, only the connected component to which it belongs is considered.

<a id='LightGraphs.condensation' href='#LightGraphs.condensation'>#</a>
**`LightGraphs.condensation`** &mdash; *Function*.



Computes the condensation graph of the strongly connected components.

Returns the condensation graph associated with `g`. The condensation `h` of a graph `g` is the directed graph where every node in `h` represents a strongly connected component in `g`, and the presence of an edge between between nodes in `h` indicates that there is at least one edge between the associated strongly connected components in `g`. The node numbering in `h` corresponds to the ordering of the components output from `strongly_connected_components`.

<a id='LightGraphs.period' href='#LightGraphs.period'>#</a>
**`LightGraphs.period`** &mdash; *Function*.



Computes the (common) period for all nodes in a strongly connected graph.


<a id='Cycle-Detection-1'></a>

## Cycle Detection


In graph theory, a cycle is defined to be a path that starts from some vertex `v` and ends up at `v`.

<a id='LightGraphs.is_cyclic' href='#LightGraphs.is_cyclic'>#</a>
**`LightGraphs.is_cyclic`** &mdash; *Function*.



```
is_cyclic(g)
```

Tests whether a graph contains a cycle through depth-first search. It returns `true` when it finds a cycle, otherwise `false`.


<a id='Shortest-Path-Algorithms-1'></a>

## Shortest-Path Algorithms


<a id='General-properties-of-shortest-path-algorithms-1'></a>

### General properties of shortest path algorithms


  * The distance from a vertex to itself is always `0`.
  * The distance between two vertices with no connecting edge is always `Inf`.

<a id='LightGraphs.a_star' href='#LightGraphs.a_star'>#</a>
**`LightGraphs.a_star`** &mdash; *Function*.



Computes the shortest path between vertices `s` and `t` using the [A* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm). An optional heuristic function and edge distance matrix may be supplied.

<a id='LightGraphs.dijkstra_shortest_paths' href='#LightGraphs.dijkstra_shortest_paths'>#</a>
**`LightGraphs.dijkstra_shortest_paths`** &mdash; *Function*.



Performs [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) on a graph, computing shortest distances between a source vertex `s` and all other nodes. Returns a `DijkstraState` that contains various traversal information (see below).

With `allpaths=true`, returns a `DijkstraState` that keeps track of all predecessors of a given vertex (see below).

<a id='LightGraphs.bellman_ford_shortest_paths' href='#LightGraphs.bellman_ford_shortest_paths'>#</a>
**`LightGraphs.bellman_ford_shortest_paths`** &mdash; *Function*.



Uses the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm) to compute shortest paths between a source vertex `s` or a set of source vertices `ss`. Returns a `BellmanFordState` with relevant traversal information (see below).

<a id='LightGraphs.floyd_warshall_shortest_paths' href='#LightGraphs.floyd_warshall_shortest_paths'>#</a>
**`LightGraphs.floyd_warshall_shortest_paths`** &mdash; *Function*.



Uses the [Floyd-Warshall algorithm](http://en.wikipedia.org/wiki/Floyd–Warshall_algorithm) to compute shortest paths between all pairs of vertices in graph `g`. Returns a `FloydWarshallState` with relevant traversal information, each is a vertex-indexed vector of vectors containing the metric for each vertex in the graph.

Note that this algorithm may return a large amount of data (it will allocate on the order of $\mathcal{O}(nv^2)$).


<a id='Path-discovery-/-enumeration-1'></a>

## Path discovery / enumeration

<a id='LightGraphs.gdistances' href='#LightGraphs.gdistances'>#</a>
**`LightGraphs.gdistances`** &mdash; *Function*.



```
gdistances(g, source) -> dists
```

Returns a vector filled with the geodesic distances of vertices in  `g` from vertex/vertices `source`. For vertices in disconnected components the default distance is -1.

<a id='LightGraphs.gdistances!' href='#LightGraphs.gdistances!'>#</a>
**`LightGraphs.gdistances!`** &mdash; *Function*.



```
gdistances!(g, source, dists) -> dists
```

Fills `dists` with the geodesic distances of vertices in  `g` from vertex/vertices `source`. `dists` can be either a vector or a dictionary.

<a id='LightGraphs.enumerate_paths' href='#LightGraphs.enumerate_paths'>#</a>
**`LightGraphs.enumerate_paths`** &mdash; *Function*.



Given a path state `state` of type `AbstractPathState` (see below), returns a vector (indexed by vertex) of the paths between the source vertex used to compute the path state and a destination vertex `v`, a set of destination vertices `vs`, or the entire graph. For multiple destination vertices, each path is represented by a vector of vertices on the path between the source and the destination. Nonexistent paths will be indicated by an empty vector. For single destinations, the path is represented by a single vector of vertices, and will be length 0 if the path does not exist.

For Floyd-Warshall path states, please note that the output is a bit different, since this algorithm calculates all shortest paths for all pairs of vertices: `enumerate_paths(state)` will return a vector (indexed by source vertex) of vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)` will return a vector (indexed by destination vertex) of paths from source `v` to all other vertices. In addition, `enumerate_paths(state, v, d)` will return a vector representing the path from vertex `v` to vertex `d`.


For Floyd-Warshall path states, please note that the output is a bit different, since this algorithm calculates all shortest paths for all pairs of vertices: `enumerate_paths(state)` will return a vector (indexed by source vertex) of vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)` will return a vector (indexed by destination vertex) of paths from source `v` to all other vertices. In addition, `enumerate_paths(state, v, d)` will return a vector representing the path from vertex `v` to vertex `d`.


<a id='Path-States-1'></a>

### Path States


The `floyd_warshall_shortest_paths`, `bellman_ford_shortest_paths`, `dijkstra_shortest_paths`, and `dijkstra_predecessor_and_distance` functions return a state that contains various information about the graph learned during traversal. The three state types have the following common information, accessible via the type:


`.dists` Holds a vector of distances computed, indexed by source vertex.


`.parents` Holds a vector of parents of each source vertex. The parent of a source vertex is always `0`.


In addition, the `dijkstra_predecessor_and_distance` function stores the following information:


`.predecessors` Holds a vector, indexed by vertex, of all the predecessors discovered during shortest-path calculations. This keeps track of all parents when there are multiple shortest paths available from the source.


`.pathcounts` Holds a vector, indexed by vertex, of the path counts discovered during traversal. This equals the length of each subvector in the `.predecessors` output above.

