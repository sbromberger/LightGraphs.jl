# Path and Traversal

*LightGraphs.jl* provides several traversal and shortest-path algorithms, along with
various utility functions. Where appropriate, edge distances may be passed in as a
matrix of real number values.

Edge distances for most traversals may be passed in as a sparse or dense matrix
of  values, indexed by `[src,dst]` vertices. That is, `distmx[2,4] = 2.5`
assigns the distance `2.5` to the (directed) edge connecting vertex 2 and vertex 4.
Note that also for undirected graphs `distmx[4,2]` has to be set.

Any graph traversal  will traverse an edge only if it is present in the graph. When a distance matrix is passed in,

1. distance values for undefined edges will be ignored, and
2. any unassigned values (in sparse distance matrices), for edges that are present in the graph, will be assumed to take the default value of 1.0.
3. any zero values (in sparse/dense distance matrices), for edges that are present in the graph, will instead have an implicit edge cost of 1.0.

## Graph Traversal

*Graph traversal* refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements three traversal schemes:

* `BreadthFirst`,
* `DepthFirst`, and
* `MaximumAdjacency`.

```@docs
bfs_tree
dfs_tree
maximum_adjacency_visit
```

## Random walks

*LightGraphs* includes uniform random walks and self avoiding walks:

```@docs
randomwalk
saw
```

## Connectivity / Bipartiteness

`Graph connectivity` functions are defined on both undirected and directed graphs:

```@docs
is_connected
is_strongly_connected
is_weakly_connected
connected_components
strongly_connected_components
weakly_connected_components
has_self_loop
attracting_components
is_bipartite
condensation
period
```

## Cycle Detection

In graph theory, a cycle is defined to be a path that starts from some vertex
`v` and ends up at `v`.

```@docs
is_cyclic
```

## Shortest-Path Algorithms

### General properties of shortest path algorithms

* The distance from a vertex to itself is always `0`.
* The distance between two vertices with no connecting edge is always `Inf`.

```@docs
a_star
dijkstra_shortest_paths
bellman_ford_shortest_paths
floyd_warshall_shortest_paths
```

## Path discovery / enumeration

```@docs
gdistances
gdistances!
enumerate_paths
```

### Path States

The `floyd_warshall_shortest_paths`, `bellman_ford_shortest_paths`,
`dijkstra_shortest_paths`, and `dijkstra_predecessor_and_distance` functions
return a state that contains various information about the graph learned during
traversal. The three state types have the following common information,
accessible via the type:

`.dists`
Holds a vector of distances computed, indexed by source vertex.

`.parents`
Holds a vector of parents of each source vertex. The parent of a source vertex
is always `0`.

In addition, the `dijkstra_predecessor_and_distance` function stores the
following information:

`.predecessors`
Holds a vector, indexed by vertex, of all the predecessors discovered during
shortest-path calculations. This keeps track of all parents when there are
multiple shortest paths available from the source.

`.pathcounts`
Holds a vector, indexed by vertex, of the path counts discovered during
traversal. This equals the length of each subvector in the `.predecessors`
output above.
