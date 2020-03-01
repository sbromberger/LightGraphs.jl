"""
    closeness_centrality(g, distmx=weights(g); normalize=true)

Calculate the [closeness centrality](https://en.wikipedia.org/wiki/Centrality#Closeness_centrality)
of the graph `g`. Return a vector representing the centrality calculated for each node in `g`.

### Optional Arguments
- `normalize=true`: If true, normalize the centrality value of each
node `n` by ``\\frac{|δ_n|}{|V|-1}``, where ``δ_n`` is the set of vertices reachable
from node `n`.

# Examples
```jldoctest
julia> using LightGraphs

julia> closeness_centrality(star_graph(5))
5-element Array{Float64,1}:
 1.0
 0.5714285714285714
 0.5714285714285714
 0.5714285714285714
 0.5714285714285714

julia> closeness_centrality(path_graph(4))
4-element Array{Float64,1}:
 0.5
 0.75
 0.75
 0.5
```
"""
function closeness_centrality(g::AbstractGraph,
    distmx::AbstractMatrix=weights(g);
    normalize=true)

    n_v = nv(g)
    closeness = zeros(n_v)

    for u in vertices(g)
        if degree(g, u) == 0     # no need to do Dijkstra here
            closeness[u] = 0.0
        else
            d = dists(shortest_paths(g, u, distmx, Dijkstra()))
            δ = filter(x -> x != typemax(x), d)
            σ = sum(δ)
            l = length(δ) - 1
            if σ > 0
                closeness[u] = l / σ
                if normalize
                    n = l / (n_v - 1)
                    closeness[u] *= n
                end
            end
        end
    end
    return closeness
end
