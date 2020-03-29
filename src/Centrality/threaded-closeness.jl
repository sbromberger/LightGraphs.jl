
"""
    struct ThreadedCloseness <: CentralityMeasure
        normalize::Bool
    end

A struct representing a threaded algorithm to calculate the [closeness centrality](https://en.wikipedia.org/wiki/Centrality#Closeness_centrality)
of the graph `g`.

### Optional Arguments
- `normalize=true`: If true, normalize the centrality value of each
node `n` by ``\\frac{|δ_n|}{|V|-1}``, where ``δ_n`` is the set of vertices reachable
from node `n`.

# Examples
```jldoctest
julia> using LightGraphs

julia> centrality(star_graph(5), ThreadedCloseness())
5-element Array{Float64,1}:
 1.0
 0.5714285714285714
 0.5714285714285714
 0.5714285714285714
 0.5714285714285714

 julia> centrality(path_graph(4), Closeness())
4-element Array{Float64,1}:
 0.5
 0.75
 0.75
 0.5
```
"""
struct ThreadedCloseness <: CentralityMeasure
    normalize::Bool
end

# internal function so we don't have to duplicate a lot of code.
function _threaded_closeness_centrality(g::AbstractGraph, distmx, alg::ThreadedCloseness, use_distmx::Bool)::Vector{Float64}
    n_v = Int(nv(g))
    closeness = Vector{Float64}(undef, n_v)

    Base.Threads.@threads for u in vertices(g)
        if degree(g, u) == 0     # no need to do SP here
            closeness[u] = 0.0
        else
            d = use_distmx ? ShortestPaths.dists(ShortestPaths.shortest_paths(g, u, distmx, ShortestPaths.Dijkstra())) :
                             ShortestPaths.dists(ShortestPaths.shortest_paths(g, u, ShortestPaths.BFS()))
            δ = filter(x -> x != typemax(x), d)
            σ = sum(δ)
            l = length(δ) - 1
            if σ > 0
                closeness[u] = l / σ
                if alg.normalize
                    n = l * 1.0 / (n_v - 1)
                    closeness[u] *= n
                end
            end
        end
    end
    return closeness
end

centrality(g::AbstractGraph, distmx::AbstractMatrix, alg::ThreadedCloseness)::Vector{Float64} =
    _threaded_closeness_centrality(g, distmx, alg, true)

centrality(g::AbstractGraph, alg::ThreadedCloseness)::Vector{Float64} =
    _threaded_closeness_centrality(g, zeros(0,0), alg, false)
