"""
    struct DistributedRadiality end

A struct describing a distributed algorithm to calculate the [radiality centrality](http://www.cbmc.it/fastcent/doc/Radiality.htm)
of a graph `g` across all vertices.

See [`Radiality`](@ref) for more information.
"""
struct DistributedRadiality <: CentralityMeasure end


function centrality(g::AbstractGraph{T}, ::DistributedRadiality)::Vector{Float64} where {T}
    n_v = nv(g)
    vs = vertices(g)
    n = ne(g)
    meandists = SharedVector{Float64}(Int(n_v))
    maxdists = SharedVector{T}(Int(n_v))

    @sync @distributed for i = 1:n_v
        d = ShortestPaths.shortest_paths(g, vs[i], ShortestPaths.BFS())
        maxdists[i] = maximum(ShortestPaths.distances(d))
        meandists[i] = Float64(sum(ShortestPaths.distances(d))) / Float64(n_v - 1)
        nothing
    end
    dmtr = Float64(maximum(maxdists))
    radialities = collect(meandists)
    return ((dmtr + one(Float64)) .- radialities) ./ dmtr
end
