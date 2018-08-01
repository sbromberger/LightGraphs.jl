# Parallel Graph Algorithms

LightGraphs.Parallel is a module for graph algorithms that are parallelized. Their names should be consistent with the
serial versions in the main module. In order to use parallel versions of the algorithms you can write:

```julia
using LightGraphs
import LightGraphs.Parallel

g = PathGraph(10)
bc = Parallel.betweenness_centrality(g)
```

The arguments to parallel versions of functions match as closely as possible their serial versions 
with potential addition default or keyword arguments to control parallel execution. 
One exception is that for algorithms that cannot be meaningfully parallelized for 
certain types of arguments a MethodError will be raised.
For example, `dijkstra_shortest_paths` works for either a single or multiple source argument,
but since the parallel version is slower when given only a single source, it will raise a `MethodError`.

```julia
g = Graph(10)
# these work
LightGraphs.dijkstra_shortest_paths(g,1)
LightGraphs.dijkstra_shortest_paths(g, [1,2])
Parallel.dijkstra_shortest_paths(g, [1,2])
# this doesn't
Parallel.dijkstra_shortest_paths(g,1)
```

Note that after `import`ing or `using` `LightGraphs.Parallel`, you must fully qualify the version of the function you wish to use (using, _e.g._, `LightGraphs.betweenness_centrality(g)` for the sequential version and
`Parallel.betweenness_centrality(g)` for the parallel version.)

The following is a current list of parallel algorithms:
- `Parallel.betweenness_centrality`
- `Parallel.closeness_centrality`
- `Parallel.radiality_centrality`
- `Parallel.stress_centrality`
- `Parallel.center`
- `Parallel.diameter`
- `Parallel.eccentricity`
- `Parallel.radius`


