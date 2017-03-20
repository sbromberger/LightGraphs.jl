"""
modularity(g, c)

Computes Newman's modularity `Q`
for graph `g` given the partitioning `c`.
"""
function modularity end
@traitfn function modularity(g::::(!IsDirected), c::Vector)
    m = 2*ne(g)
    m == 0 && return 0.
    nc = maximum(c)
    a = zeros(Int,nc)
    Q = 0
    for u in vertices(g)
        for v in neighbors(g,u)
            if u <= v
                c1 = c[u]
                c2 = c[v]
                if c1 == c2
                    Q += 2
                end
                a[c1] += 1
                a[c2] += 1
            end
        end
    end
    Q = Q*m
    @inbounds for i=1:nc
        Q -= a[i]*a[i]
    end
    return Q/m/m
end
