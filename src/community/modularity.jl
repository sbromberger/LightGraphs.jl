"""
    modularity(g, c)

Computes Newman's modularity `Q`
for graph `g` given the partitioning `c`.
"""
function modularity(g::Graph, c)
    n = nv(g)
    m = 2*ne(g)
    m == 0 && return 0.0
    e = zeros(Int,n)
    a = zeros(Int,n)
    for u in vertices(g)
        for v in neighbors(g,u)
            if u <= v
                c1 = c[u]
                c2 = c[v]
                if c1 == c2
                    e[c1] += 2
                end
                a[c1] += 1
                a[c2] += 1
            end
        end
    end

    Q = 0
    @inbounds for i=1:n
        Q += e[i]*m - a[i]*a[i]
    end
    return Q/m/m
end
