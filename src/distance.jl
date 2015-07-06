# used in shortest path calculations
# has_distances{T}(distmx::AbstractArray{T,2}) =
#     issparse(distmx)? (nnz(distmx) > 0) : !isempty(distmx)

type DefaultDistance<:AbstractArray{Int, 2}
end

getindex(::DefaultDistance, s::Int, d::Int) = (s==d)? 0 : 1


function eccentricity{T}(
    g::SimpleGraph,
    v::Int,
    distmx::AbstractArray{T, 2} = DefaultDistance()
)
    e = maximum(dijkstra_shortest_paths(g,v,distmx).dists)
    if e == typemax(T)
        error("Infinite path length detected")
    else
        return e
    end
end

eccentricity{T}(
    g::SimpleGraph,
    vs::AbstractArray{Int, 1}=vertices(g),
    distmx::AbstractArray{T, 2} = DefaultDistance()
) =
    [eccentricity(g,v,distmx) for v in vs]

eccentricity{T}(g::SimpleGraph, distmx::AbstractArray{T, 2}) =
    eccentricity(g, vertices(g), distmx)

diameter{T}(all_e::Vector{T}) = maximum(all_e)
diameter{T}(g::SimpleGraph, distmx::AbstractArray{T, 2} = DefaultDistance()) =
    maximum(eccentricity(g, distmx))

function periphery{T}(all_e::Vector{T})

    diam = maximum(all_e)
    return filter((x)->all_e[x] == diam, 1:length(all_e))
end

periphery{T}(g::SimpleGraph, distmx::AbstractArray{T, 2} = DefaultDistance()) =
    periphery(eccentricity(g, distmx))

radius{T}(all_e::Vector{T}) = minimum(all_e)
radius{T}(g::SimpleGraph, distmx::AbstractArray{T, 2} = DefaultDistance()) =
    minimum(eccentricity(g, distmx))

function center{T}(all_e::Vector{T})
    rad = radius(all_e)
    return filter((x)->all_e[x] == rad, 1:length(all_e))
end

center{T}(g::SimpleGraph, distmx::AbstractArray{T, 2} = DefaultDistance()) =
    center(eccentricity(g, distmx))
