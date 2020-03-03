# deprecations should also include a comment stating the version
# for which the deprecation should be removed.

# Deprecated to fix spelling. Can be removed for version 2.0.
@deprecate simplecycles_hadwick_james simplecycles_hawick_james

# Deprecated for more explicit function name. Can be removed for version 2.0.
@deprecate saw self_avoiding_walk


@deprecate a_star(g::AbstractGraph, s::Integer, t::Integer) shortest_paths(g, s, t, AStar())
@deprecate a_star(g::AbstractGraph, s::Integer, t::Integer, distmx::AbstractMatrix) shortest_paths(g, s, t, distmx, AStar())
@deprecate a_star(g::AbstractGraph, s::Integer, t::Integer, distmx::AbstractMatrix, heuristic::Function) shortest_paths(g, s, t, distmx, AStar(heuristic=heuristic))

@deprecate bellman_ford_shortest_paths(g::AbstractGraph, ss::Vector) shortest_paths(g, ss, BellmanFord())
@deprecate bellman_ford_shortest_paths(g::AbstractGraph, ss::Vector, distmx::AbstractMatrix) shortest_paths(g, ss, distmx, BellmanFord())
@deprecate bellman_ford_shortest_paths(g::AbstractGraph, s::Integer) shortest_paths(g, s, BellmanFord())
@deprecate bellman_ford_shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix) shortest_paths(g, s, distmx, BellmanFord())

@deprecate maxsimplecycles Cycles.max_simple_cycles
@deprecate simplecycles(g) Cycles.simple_cycles(g, Cycles.Johnson())
@deprecate simplecyclescount Cycles.count_simple_cycles
@deprecate simplecycles_hawick_james(g) Cycles.simple_cycles(g, Cycles.HawickJames())
@deprecate simplecycles_limited_length(g, n) Cycles.simple_cycles(g, Cycles.LimitedLength(n))
@deprecate simplecycles_limited_length(g, n, ceiling) Cycles.simple_cycles(g, Cycles.LimitedLength(n, ceiling))
@deprecate simplecycleslength(g, ceil) Cycles.simple_cycles_length(g, Cycles.Johnson(ceiling=ceil))
@deprecate karp_minimum_cycle_mean(g) Cycles.minimum_cycle_mean(g, Cycles.Karp())
@deprecate karp_minimum_cycle_mean(g, distmx) Cycles.minimum_cycle_mean(g, distmx, Cycles.Karp())

@deprecate enumerate_paths paths
@deprecate bfs_tree(g, v) tree(shortest_paths(g, v, BFS()))
@deprecate dfs_tree(g, v) tree(shortest_paths(g, v, DepthFirst()))
@deprecate bfs_parents(g, v) ShortestPaths.parents(ShortestPaths.shortest_paths(g, v, BFS()))
@deprecate gdistances Traversals.distances
@deprecate topological_sort_by_dfs(g) Traversals.topological_sort(g, Traversals.DepthFirst())
@deprecate transitivereduction transitive_reduction
@deprecate transitiveclosure transitive_closure

export maxsimplescycles, simplecyclescount, simplecycleslength, enumerate_paths, bfs_tree, dfs_tree, transitivereduction, transitiveclosure
