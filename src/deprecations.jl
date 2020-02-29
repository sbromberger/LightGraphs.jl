# deprecations should also include a comment stating the version
# for which the deprecation should be removed.

# Deprecated to fix spelling. Can be removed for version 2.0.
@deprecate simplecycles_hadwick_james simplecycles_hawick_james

# Deprecated for more explicit function name. Can be removed for version 2.0.
@deprecate saw self_avoiding_walk

@deprecate a_star(g::AbstractGraph, s, t, distmx::AbstractMatrix, heuristic::Function) shortestpaths(g, s, t, distmx, AStar(heuristic=heuristic))
@deprecate a_star(g::AbstractGraph, s, t, distmx::AbstractMatrix) shortestpaths(g, s, t, distmx, AStar())
@deprecate a_star(g::AbstractGraph, s, t) shortestpaths(g, s, t, AStar())
