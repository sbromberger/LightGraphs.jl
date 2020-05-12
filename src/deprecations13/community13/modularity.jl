function modularity(
    g::AbstractGraph,
    c::AbstractVector{<:Integer};
    distmx::AbstractArray{<:Number}=weights(g),
    γ=1.0
    )

  Base.depwarn("`modularity` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.modularity`.", :modularity)
  LightGraphs.Community.modularity(g, c, distmx=distmx, γ=γ)
end
