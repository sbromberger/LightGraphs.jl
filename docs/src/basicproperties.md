
```@index
Order = [:type, :function]
Pages   = ["basicmeasures.md"]
```

# Accessing Graph Properties


## Whole-Graph Properties:

- `nv`: number of vertices in graph
- `ne`: number of edges in graph
- `vertices`: Iterable object of all graph vertices
- `edges`: Iterable object of all graph edges
- `has_vertex`: Checks for whether graph includes a vertex
- `has_edge`: Checks for whether graph includes an edge
- `has_self_loops` Checks for self-loops
- `is_directed` Checks if graph is directed
- `eltype` Returns element type of graphs

## Vertex Properties

- `neighbors`: Return array of neighbors of a vertex. If graph is directed,
output is equivalent of `out_neighbors`.
- `all_neighbors`:  Returns array of all neighbors (both `in_neighbors` and `out_neighbors`).
For undirected graphs, equivalent to `neighbors`.
- `in_neighbors`: Return array of in-neighbors. Equivalent to `neighbors` for undirected graphs.
- `out_neighbors`: Return array of out-neighbors. Equivalent to `neighbors` for undirected graphs.


## Edge Properties

- `src`: Give source vertex of an edge
- `dst`: Give destination vertex of an edge
- `reverse`: Creates a new edge running in opposite direction of passed edge


# All network properties and constructors.

```@autodocs
Modules = [LightGraphs]
Order = [:type, :function]
Pages   = ["interface.jl", "core.jl", "graph.jl", "digraph.jl", "edgeiter.jl","connectivity.jl"]
Private = false
```
