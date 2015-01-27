function eccentricity(g::AbstractSimpleGraph, v::Int)
    e = maximum(dijkstra_shortest_paths(g,v).dists)
    if isinf(e)
        error("Infinite path length detected")
    else
        return e
    end
end

_all_eccentricities(g::AbstractSimpleGraph) = [eccentricity(g,v) for v in vertices(g)]

diameter(all_e::Vector{Float64}) = maximum(all_e)
diameter(g::AbstractSimpleGraph) = maximum(_all_eccentricities(g))

function periphery(all_e::Vector{Float64})

    diam = maximum(all_e)
    return filter((x)->all_e[x] == diam, 1:length(all_e))
end

periphery(g::AbstractSimpleGraph) = periphery(_all_eccentricities(g))

radius(all_e::Vector{Float64}) = minimum(all_e)
radius(g::AbstractSimpleGraph) = minimum(_all_eccentricities(g))

function center(all_e::Vector{Float64})
    rad = radius(all_e)
    return filter((x)->all_e[x] == rad, 1:length(all_e))
end

center(g::AbstractSimpleGraph) = center(_all_eccentricities(g))
