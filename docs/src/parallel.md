# Parallel Graph Algorithms

LightGraphs.Parallel is a module for graph algorithms that are parallelized. Their names should be consistent with the
serial versions in the main module. In order to use parallel versions of the algorithms you can write:

```julia
using LightGraphs
import LightGraphs.Parallel

g = PathGraph(10)
bc = Parallel.betweenness_centrality(g)
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


