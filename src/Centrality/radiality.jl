"""
    struct Radiality end

A struct describing an algorithm to calculate the [radiality centrality](http://www.cbmc.it/fastcent/doc/Radiality.htm)
of a graph `g` across all vertices.

The radiality centrality ``R_u`` of a vertex ``u`` is defined as
``
R_u = \\frac{D_g + 1 - \\frac{\\sum_{v∈V}d_{u,v}}{|V|-1}}{D_g}
``

where ``D_g`` is the diameter of the graph and ``d_{u,v}`` is the 
length of the shortest path from ``u`` to ``v``.

### References
- Brandes, U.: A faster algorithm for betweenness centrality. J Math Sociol 25 (2001) 163-177

# Examples
```jldoctest
julia> using LightGraphs

julia> centrality(star_graph(4), Radiality())
4-element Array{Float64,1}:
 1.0               
 0.6666666666666666
 0.6666666666666666
 0.6666666666666666

 julia> centrality(path_graph(3), Radiality())
3-element Array{Float64,1}:
 0.75
 1.0 
 0.75
```
"""
struct Radiality <: CentralityMeasure end

function centrality(g::AbstractGraph, ::Radiality)::Vector{Float64}
    n_v = nv(g)
    vs = vertices(g)

    meandists = zeros(Float64, n_v)
    dmtr = 0
    for v in vs
        d = ShortestPaths.shortest_paths(g, v, ShortestPaths.BFS())
        dmtr = max(dmtr, maximum(ShortestPaths.distances(d)))
        meandists[v] = sum(ShortestPaths.distances(d)) / (n_v - 1) # ignore the source vx
    end
    meandists = (dmtr + 1) .- (meandists)
    return meandists ./ Float64(dmtr)
end
