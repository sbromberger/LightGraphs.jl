# @doc doc"""
#         closeness_centrality(g::AbstractGraph; normalize=true)
#
#     Computes closeness centrality of a graph, based on all vertices.
#     """ ->
function closeness_centrality(
    g::AbstractGraph;
    normalize=true)

    n_v = nv(g)
    closeness = zeros(n_v)

    for u = 1:n_v
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
    return closeness
end
