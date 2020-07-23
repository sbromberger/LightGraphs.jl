function articulation(g)
    Base.depwarn("`articulation` is deprecated. Equivalent functionality has been moved to `LightGraphs.Biconnectivity.articulation`.", :articulation)
    LightGraphs.Biconnectivity.articulation(g)
end

function bridges(g)
    Base.depwarn("`bridges` is deprecated. Equivalent functionality has been moved to `LightGraphs.Biconnectivity.bridges`.", :bridges)
    LightGraphs.Biconnectivity.bridges(g)
end

function biconnected_components(g)
    Base.depwarn("`biconnected_components` is deprecated. Equivalent functionality has been moved to `LightGraphs.Biconnectivity.biconnected_components`.", :biconnected_components)
    LightGraphs.Biconnectivity.biconnected_components(g)
end
