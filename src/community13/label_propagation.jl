function label_propagation(g::AbstractGraph{T}, maxiter=1000) where T
  Base.depwarn("`label_propagation` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.communities`.", :label_propagation)
  LightGraphs.Community.communities(g, LightGraphs.Community.LabelPropagation(maxiter))
end
