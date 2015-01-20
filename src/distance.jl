eccentricity(g::AbstractFastGraph, v::Int) = maximum(dijkstra_shortest_paths(g,v).dists)

_all_eccentricities(g::AbstractFastGraph) = [eccentricity(g,v) for v in vertices(g)]

diameter(g::AbstractFastGraph, all_e::Vector{Float64}) = maximum(all_e)
diameter(g::AbstractFastGraph) = maximum(g, _all_eccentricities(g))

function periphery(g::AbstractFastGraph, all_e::Vector{Float64})

    diam = maximum(all_e)
    return filter((x)->all_e[x] == diam, 1:length(all_e))
end

periphery(g::AbstractFastGraph) = periphery(g, _all_eccentricities(g))

radius(g::AbstractFastGraph, all_e::Vector{Float64}) = minimum(all_e)
radius(g::AbstractFastGraph) = minimum(g, _all_eccentricities(g))

function center(g::AbstractFastGraph, all_e::Vector{Float64})
    rad = radius(g,all_e)
    return filter((x)->all_e[x] == rad, 1:length(all_e))
end

center(g::AbstractFastGraph) = center(g, _all_eccentricities(g))
