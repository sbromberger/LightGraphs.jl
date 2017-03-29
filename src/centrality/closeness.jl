"""Calculates the [closeness centrality](https://en.wikipedia.org/wiki/Centrality#Closeness_centrality)
of the graph `g`.
"""
function closeness_centrality(
    g::SimpleGraph;
    normalize=true)

    n_v = nv(g)
    closeness = zeros(n_v)

    for u = 1:n_v
        if degree(g, u) == 0     # no need to do Dijkstra here
            closeness[u] = 0.0
        else
            d = dijkstra_shortest_paths(g,u).dists
            δ = filter(x->x != typemax(x), d)
            σ = sum(δ)
            l = length(δ) - 1
            if σ > 0
                closeness[u] = l / σ

                if normalize
                    n = l / (n_v-1)
                    closeness[u] *= n
                end
            end
        end
    end
    return closeness
end
