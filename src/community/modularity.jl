"""
Computes Newman's modularity `Q`
for graph `g` given the partitioning `c`.
"""
function modularity(g::Graph, c)
    Q = 0.
    m = 2 * ne(g)
    m == 0 && return 0.
    for u in vertices(g)
        for v in vertices(g)
            c[u] != c[v] && continue
            a = has_edge(g, u, v) ? 1 : 0
            Q += a - degree(g, u)*degree(g, v) / m
        end
    end
    return Q / m
end
