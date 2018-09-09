# Path and Traversal

*LightGraphs.jl* provides several traversal and shortest-path algorithms, along with
various utility functions. Where appropriate, edge distances may be passed in as a
matrix of real number values.

Edge distances for most traversals may be passed in as a sparse or dense matrix
of  values, indexed by `[src,dst]` vertices. That is, `distmx[2,4] = 2.5`
assigns the distance `2.5` to the (directed) edge connecting vertex 2 and vertex 4.
Note that also for undirected graphs `distmx[4,2]` has to be set.

Default edge distances may be passed in via the
```@docs
LightGraphs.DefaultDistance
```
structure.

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
bfs_parents
has_path
diffusion
diffusion_rate
mincut
```

## Random walks

*LightGraphs* includes uniform random walks and self avoiding walks:

```@docs
randomwalk
non_backtracking_randomwalk
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
has_self_loops
attracting_components
is_bipartite
bipartite_map
biconnected_components
condensation
neighborhood
neighborhood_dists
articulation
period
isgraphical
```

## Cycle Detection

In graph theory, a cycle is defined to be a path that starts from some vertex
`v` and ends up at `v`.

```@docs
is_cyclic
maxsimplecycles
simplecycles
simplecycles_iter
simplecycles_hawick_james
simplecyclescount
simplecycleslength
simplecycles_limited_length
karp_minimum_cycle_mean
```

## Minimum Spanning Trees (MST) Algorithms

A Minimum Spanning Tree (MST) is a subset of the edges of a connected, edge-weighted (un)directed graph that connects all the vertices together, without any cycles and with the minimum possible total edge weight.

```@docs
kruskal_mst
prim_mst
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
yen_k_shortest_paths
```

## Path discovery / enumeration

```@docs
gdistances
gdistances!
enumerate_paths
```

### Path States

All path states derive from
```@docs
LightGraphs.AbstractPathState
```

The `dijkstra_shortest_paths`, `floyd_warshall_shortest_paths`,
`bellman_ford_shortest_paths`, and `yen_shortest_paths` functions 
return states that contain various  information about the graph
learned during traversal. 

```@docs
LightGraphs.DijkstraState
LightGraphs.BellmanFordState
LightGraphs.FloydWarshallState
LightGraphs.YenState
```
The above state types (with the exception of `YenState`) have the following common
information, accessible via the type:

`.dists`
Holds a vector of distances computed, indexed by source vertex.

`.parents`
Holds a vector of parents of each source vertex. The parent of a source vertex
is always `0`.

(`YenState` substitutes `.paths` for `.parents`.)

In addition, the following information may be populated with the appropriate
arguments to `dijkstra_shortest_paths`:

`.predecessors`
Holds a vector, indexed by vertex, of all the predecessors discovered during
shortest-path calculations. This keeps track of all parents when there are
multiple shortest paths available from the source.

`.pathcounts`
Holds a vector, indexed by vertex, of the path counts discovered during
traversal. This equals the length of each subvector in the `.predecessors`
output above.
