eccentricity(g::AbstractFastGraph, v::Int) = maximum(dijkstra_shortest_paths(g,v).dists)

_all_eccentricities(g::AbstractFastGraph) = [eccentricity(g,v) for v in vertices(g)]

diameter(all_e::Vector{Float64}) = maximum(all_e)
diameter(g::AbstractFastGraph) = maximum(_all_eccentricities(g))

function periphery(all_e::Vector{Float64})

    diam = maximum(all_e)
    return filter((x)->all_e[x] == diam, 1:length(all_e))
end

periphery(g::AbstractFastGraph) = periphery(_all_eccentricities(g))

radius(all_e::Vector{Float64}) = minimum(all_e)
radius(g::AbstractFastGraph) = minimum(_all_eccentricities(g))

function center(all_e::Vector{Float64})
    rad = radius(all_e)
    return filter((x)->all_e[x] == rad, 1:length(all_e))
end

center(g::AbstractFastGraph) = center(_all_eccentricities(g))
