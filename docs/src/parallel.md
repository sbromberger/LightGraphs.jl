# Parallel Graph Algorithms

LightGraphs.Parallel is a module for graph algorithms that are parallelized. Their names should be consistent with the
serial versions in the main module. In order to use parallel versions of the algorithms you can write:

```julia
using LightGraphs
import LightGraphs.Parallel

g = Graph(10)
v = 1
paths = Parallel.dijkstra_shortest_paths(g, v)
```
