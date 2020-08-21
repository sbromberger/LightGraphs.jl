@traitfn function maximal_cliques(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}}
  Base.depwarn("`maximal_cliques` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.communities`.", :maximal_cliques)
  LightGraphs.Community.maximal_cliques(g)
end
