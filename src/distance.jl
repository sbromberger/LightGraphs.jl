# used in shortest path calculations
has_distances{T}(edge_dists::AbstractArray{T,2}) =
    issparse(edge_dists)? (nnz(edge_dists) > 0) : !isempty(edge_dists)

function eccentricity(
    g::AbstractGraph,
    v::Int;
    edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))
)
    e = maximum(dijkstra_shortest_paths(g,v; edge_dists=edge_dists).dists)
    if isinf(e)
        error("Infinite path length detected")
    else
        return e
    end
end

eccentricity(
    g::AbstractGraph,
    vs::AbstractArray{Int, 1}=vertices(g);
    edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))
) =
    [eccentricity(g,v; edge_dists=edge_dists) for v in vs]

diameter(all_e::Vector{Float64}) = maximum(all_e)
diameter(g::AbstractGraph; edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))) =
    maximum(eccentricity(g; edge_dists=edge_dists))

function periphery(all_e::Vector{Float64})

    diam = maximum(all_e)
    return filter((x)->all_e[x] == diam, 1:length(all_e))
end

periphery(g::AbstractGraph; edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))) =
    periphery(eccentricity(g; edge_dists=edge_dists))

radius(all_e::Vector{Float64}) = minimum(all_e)
radius(g::AbstractGraph; edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))) =
    minimum(eccentricity(g; edge_dists=edge_dists))

function center(all_e::Vector{Float64})
    rad = radius(all_e)
    return filter((x)->all_e[x] == rad, 1:length(all_e))
end

center(g::AbstractGraph; edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))) =
    center(eccentricity(g; edge_dists=edge_dists))
