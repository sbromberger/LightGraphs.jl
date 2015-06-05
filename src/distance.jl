# used in shortest path calculations
has_distances{T}(edge_dists::AbstractArray{T,2}) =
    issparse(edge_dists)? (nnz(edge_dists) > 0) : !isempty(edge_dists)

type DefaultDistance<:AbstractArray{Int, 2}
end

getindex(::DefaultDistance, ::Int, ::Int) = 1


function eccentricity{T}(
    g::AbstractGraph,
    v::Int,
    edge_dists::AbstractArray{T, 2} = DefaultDistance()
)
    e = maximum(dijkstra_shortest_paths(g,v,edge_dists).dists)
    if e == typemax(T)
        error("Infinite path length detected")
    else
        return e
    end
end

eccentricity{T}(
    g::AbstractGraph,
    vs::AbstractArray{Int, 1}=vertices(g),
    edge_dists::AbstractArray{T, 2} = DefaultDistance()
) =
    [eccentricity(g,v,edge_dists) for v in vs]

eccentricity{T}(g::AbstractGraph, edge_dists::AbstractArray{T, 2}) =
    eccentricity(g, vertices(g), edge_dists)

diameter{T}(all_e::Vector{T}) = maximum(all_e)
diameter{T}(g::AbstractGraph, edge_dists::AbstractArray{T, 2} = DefaultDistance()) =
    maximum(eccentricity(g, edge_dists))

function periphery{T}(all_e::Vector{T})

    diam = maximum(all_e)
    return filter((x)->all_e[x] == diam, 1:length(all_e))
end

periphery{T}(g::AbstractGraph, edge_dists::AbstractArray{T, 2} = DefaultDistance()) =
    periphery(eccentricity(g, edge_dists))

radius{T}(all_e::Vector{T}) = minimum(all_e)
radius{T}(g::AbstractGraph, edge_dists::AbstractArray{T, 2} = DefaultDistance()) =
    minimum(eccentricity(g, edge_dists))

function center{T}(all_e::Vector{T})
    rad = radius(all_e)
    return filter((x)->all_e[x] == rad, 1:length(all_e))
end

center{T}(g::AbstractGraph, edge_dists::AbstractArray{T, 2} = DefaultDistance()) =
    center(eccentricity(g, edge_dists))
