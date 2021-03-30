"""
    rich_club(g, k)

Return the non-normalised [rich-club coefficient](https://en.wikipedia.org/wiki/Rich-club_coefficient) of graph `g`,
with degree cut-off `k`.

```jldoctest
julia> using LightGraphs
julia> g = star_graph(5)
julia> rich_club(g, 1)
0.4
```
"""
function rich_club(g::AbstractGraph{T}, k::Int) where T
    E = zero(T)
    for e in edges(g)
        if (outdegree(g, src(e)) >= k) && (indegree(g, dst(e)) >= k )
            E +=1
        end
    end
    N = count(degree(g) .>= k)
    if is_directed(g)
        return E / (N*(N-1))
    else
        return 2*E / (N*(N-1))
    end
end
