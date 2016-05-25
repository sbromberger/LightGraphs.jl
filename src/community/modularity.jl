"""
    modularity(g, c)

Computes Newman's modularity `Q`
for graph `g` given the partitioning `c`.
"""
function modularity(g::Graph, c)
    m = ne(g)
    m == 0 && (return 0.0)
    labels = unique(c)
    length(labels) == 1 && (return 0.0)
    e = Dict{Int,Int}()
    a = Dict{Int,Int}()
    for edge in edges(g)
        c1 = c[src(edge)]
        c2 = c[dst(edge)]
        if c1 == c2
            e[c1] = get(e,c1,0) + 2
        end
        a[c1] = get(a,c1,0) + 1
        a[c2] = get(a,c2,0) + 1
    end
    Q = 0.0
    for label in labels
        tmp = get(a,label,0)/2/m
        Q += get(e,label,0)/2/m
        Q -= tmp*tmp
    end
    return Q
end
