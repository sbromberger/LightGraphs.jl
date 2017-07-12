@doc_str """
    closeness_centrality(g)

Calculate the [closeness centrality](https://en.wikipedia.org/wiki/Centrality#Closeness_centrality)
of the graph `g`. Return a vector representing the centrality calculated for each node in `g`.

### Optional Arguments
- `normalize=true`: If true, normalize the centrality value of each
node `n` by ``\\frac{|δ_n|}{|V|-1}``, where ``δ_n`` is the set of vertices reachable
from node `n`.
"""
function closeness_centrality(
    g::AbstractGraph,
    distmx::AbstractMatrix=weights(g);
    normalize=true)

    n_v = nv(g)
    closeness = zeros(n_v)

    for u in vertices(g)
        if degree(g, u) == 0     # no need to do Dijkstra here
            closeness[u] = 0.0
        else
            d = dijkstra_shortest_paths(g, u, distmx).dists
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

function parallel_closeness_centrality(
    g::AbstractGraph,
    distmx::AbstractMatrix=weights(g);
    normalize=true)::Vector{Float64}

    n_v = Int(nv(g))

    closeness = SharedVector{Float64}(n_v)

    @sync @parallel for u in vertices(g)
        if degree(g, u) == 0     # no need to do Dijkstra here
            closeness[u] = 0.0
        else
            d = dijkstra_shortest_paths(g, u, distmx).dists
            δ = filter(x -> x != typemax(x), d)
            σ = sum(δ)
            l = length(δ) - 1
            if σ > 0
                closeness[u] = l / σ
                if normalize
                    n = l * 1.0 / (n_v - 1)
                    closeness[u] *= n
                end
            end
        end
    end
    return Vector(closeness)
end
