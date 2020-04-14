function eccentricity(x...)
    Base.depwarn("`eccentricity` is deprecated. Equivalent functionality has been moved to `LightGraphs.Measurements.eccentricity`.", :eccentricity)
    LightGraphs.Measurements.eccentricity(x...)
end

function diameter(x...)
    Base.depwarn("`diameter` is deprecated. Equivalent functionality has been moved to `LightGraphs.Measurements.diameter`.", :diameter)
    LightGraphs.Measurements.diameter(x...)
end

function periphery(x...)
    Base.depwarn("`periphery` is deprecated. Equivalent functionality has been moved to `LightGraphs.Measurements.periphery`.", :periphery)
    LightGraphs.Measurements.periphery(x...)
end

function radius(x...)
    Base.depwarn("`radius` is deprecated. Equivalent functionality has been moved to `LightGraphs.Measurements.radius`.", :radius)
    LightGraphs.Measurements.radius(x...)
end

function center(x...)
    Base.depwarn("`center` is deprecated. Equivalent functionality has been moved to `LightGraphs.Measurements.center`.", :center)
    LightGraphs.Measurements.center(x...)
end
