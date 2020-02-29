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

@deprecate maxsimplecycles max_simple_cycles
@deprecate simplecyclescount count_simple_cycles
@deprecate simplecycleslength(g, ceil) simple_cycles_length(g, Johnson(ceiling=ceil))
