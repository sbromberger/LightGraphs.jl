@traitfn function karp_minimum_cycle_mean(
    g::::IsDirected,
    distmx::AbstractMatrix = weights(g)
    )
    Base.depwarn("`karp_minimum_cycle_mean` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.minimum_cycle_mean`.", :karp_minimum_cycle_mean)
    LightGraphs.Cycles.minimum_cycle_mean(g, distmx, LightGraphs.Cycles.Karp())
end
