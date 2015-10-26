"""
Computes Newman's modularity `Q`
for graph `g` given the partitioning `c`.
"""
function modularity(g::Graph, c)
    Q = 0.
    m = 2 * ne(g)
    m == 0 && return 0.
    s1 = 0
    s2 = 0
    for u in vertices(g)
        for v in vertices(g)
            c[u] != c[v] && continue
            s1 += has_edge(g, u, v) ? 1 : 0
            s2 += degree(g, u)*degree(g, v)
        end
    end
    Q = s1/m - s2/m^2
    return Q
end
