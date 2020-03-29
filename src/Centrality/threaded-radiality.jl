"""
    struct ThreadedRadiality end

A struct describing a threaded algorithm to calculate the [radiality centrality](http://www.cbmc.it/fastcent/doc/Radiality.htm)
of a graph `g` across all vertices.

See [`Radiality`](@ref) for more information.
"""
struct ThreadedRadiality <: CentralityMeasure end

function centrality(g::AbstractGraph{T}, ::ThreadedRadiality)::Vector{Float64} where {T}
    n_v = nv(g)
    vs = vertices(g)
    n = ne(g)
    meandists = Vector{Float64}(undef, n_v)
    maxdists = Vector{T}(undef, n_v)

    @threads for i in vertices(g)
        d = ShortestPaths.shortest_paths(g, vs[i], ShortestPaths.BFS())
        maxdists[i] = maximum(ShortestPaths.distances(d))
        meandists[i] = Float64(sum(ShortestPaths.distances(d))) / Float64(n_v - 1)
    end
    dmtr = Float64(maximum(maxdists))
    radialities = collect(meandists)
    return ((dmtr + one(Float64)) .- radialities) ./ dmtr
end
