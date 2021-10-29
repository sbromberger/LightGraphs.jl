"""
    s_metric(g; norm=true)

Return the normalised s-metric of `g`.

The s-metric is defined as the sum of the product of degrees between pair of vertices
for every edge in `g`. [Ref](https://arxiv.org/abs/cond-mat/0501169)
In directed graphs, the paired values are the out-degree of source vertices
and the in-degree of destination vertices.
It is normalised by the maximum s_metric obtained from the family of graph
with similar degree distribution. s_max is computed from an approximation
formula as in https://journals.aps.org/pre/pdf/10.1103/PhysRevE.75.046102
If `norm=false`, no normalisation is performed.

# Examples
```jldoctest
julia> using LightGraphs

julia> s_metric(star_graph(4))
0.6
```
"""

function s_metric(g::AbstractGraph{T}; norm=true) where T
    s = zero(T)
    for e in edges(g)
        s += outdegree(g, src(e)) * indegree(g, dst(e))
    end
    if norm
        sm = sum(degree(g).^3)/2
        return s/sm
    else
        return s
    end
end
