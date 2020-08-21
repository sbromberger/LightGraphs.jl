@traitfn function core_periphery_deg(g::::(!IsDirected))
  Base.depwarn("`core_periphery_deg` is deprecated. Equivalent functionality has been moved to `LightGraphs.Community.core_periphery`.", :core_periphery_deg)
  LightGraphs.Community.core_periphery(g, LightGraphs.Community.Degree())
end
