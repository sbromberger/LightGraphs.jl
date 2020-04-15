@traitfn function clique_percolation(g::::(!IsDirected); k = 3)
  Base.depwarn("`clique_percolation` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.communities`.", :clique_percolation)
  LightGraphs.Community.communities(g, LightGraphs.Community.CliquePercolation(k))
end
