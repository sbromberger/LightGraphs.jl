"""
    radiality_centrality(g)
    parallel_radiality_centrality(g)

Calculate the [radiality centrality](http://www.cbmc.it/fastcent/doc/Radiality.htm)
of a graph `g` across all vertices. Return a vector representing the centrality
calculated for each node in `g`.

The radiality centrality ``R_u`` of a vertex ``u`` is defined as
``
R_u = \\frac{D_g + 1 - \\frac{\\sum_{v∈V}d_{u,v}}{|V|-1}}{D_g}
``

where ``D_g`` is the diameter of the graph and ``d_{u,v}`` is the 
length of the shortest path from ``u`` to ``v``.

### References
- Brandes, U.: A faster algorithm for betweenness centrality. J Math Sociol 25 (2001) 163-177
"""
function radiality_centrality(g::AbstractGraph)::Vector{Float64}
    n_v = nv(g)
    vs = vertices(g)

    meandists = zeros(Float64, n_v)
    dmtr = 0.0
    for v in vs
        d = dijkstra_shortest_paths(g, v)
        dmtr = max(dmtr, maximum(d.dists))
        meandists[v] = sum(d.dists) / (n_v - 1) # ignore the source vx
    end
    meandists = (dmtr + 1) .- (meandists)
    return meandists ./ dmtr
end

function parallel_radiality_centrality(g::AbstractGraph)::Vector{Float64}
    n_v = nv(g)
    vs = vertices(g)
    n = ne(g)
    meandists = SharedArrays.SharedVector{Float64}(Int(n_v))
    maxdists = SharedArrays.SharedVector{Float64}(Int(n_v))

    Distributed.@sync Distributed.@distributed for i = 1:n_v
        d = dijkstra_shortest_paths(g, vs[i])
        maxdists[i] = maximum(d.dists)
        meandists[i] = sum(d.dists) / (n_v - 1)
    end
    dmtr = maximum(maxdists)
    radialities = collect(meandists)
    return ((dmtr + 1) .- radialities) ./ dmtr
end
