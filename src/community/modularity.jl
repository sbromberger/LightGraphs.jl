"""
    modularity(g, c, distmx=weights(g), γ=1.0)

Return a value representing Newman's modularity `Q` for the undirected and 
directed graph `g` given the partitioning vector `c`. This medthod also support 
weighted graphs if the distance matrix is provided.

Modularity ``Q`` for undirected graph:
```math
Q = \\frac{1}{2m} \\sum_{c} \\left( e_{c} - \\gamma \\frac{K_c^2}{2m} \\right)
```

Modularity ``Q`` for directed graph:
```math
Q = \\frac{1}{m} \\sum_{c} \\left( e_{c} - \\gamma \\frac{K_c^{in} K_c^{out}}{m} \\right)
```

where:
- ``m``: m is the total number of edges in the network 
- ``e_c``: number of edges in community ``c``
- ``K_c``: is the sum of the degrees of the nodes in community ``c`` or the 
  sum of the weighted degree of the nodes in community ``c`` when the graph is 
  weighted. ``K_c^{in}`` sum of the in-degrees of the nodes in community ``c``.

### Optional Arguments
- `distmx=weights(g)`: distance matrix for weighted graphs
- `γ=1.0`: where `γ > 0` is a resolution parameter. When the modularity is used 
  to find communities structure in networks (i.e with [Louvain's method for 
  community detection](https://en.wikipedia.org/wiki/Louvain_Modularity)), 
  higher resolutions lead to more communities, while lower resolutions lead to 
  fewer communities. Where `γ=1.0` it lead to the traditional definition of 
  the modularity.

### References
- M. E. J. Newman and M. Girvan. "Finding and evaluating community structure in networks". 
  Phys. Rev. E 69, 026113 (2004). [(arXiv)](https://arxiv.org/abs/cond-mat/0308217)
- J. Reichardt and S. Bornholdt. "Statistical mechanics of community detection". 
  Phys. Rev. E 74, 016110 (2006). [(arXiv)](https://arxiv.org/abs/cond-mat/0603718)
- E. A. Leicht and M. E. J. Newman. "Community structure in directed networks". 
  Physical Review Letter, 100:118703, (2008). [(arXiv)](https://arxiv.org/pdf/0709.4500.pdf)

# Examples 
```jldoctest
julia> using LightGraphs

julia> barbell = blockdiag(CompleteGraph(3), CompleteGraph(3));

julia> add_edge!(barbell, 1, 4);

julia> modularity(barbell, [1, 1, 1, 2, 2, 2])
0.35714285714285715

julia> modularity(barbell, [1, 1, 1, 2, 2, 2], γ=0.5)
0.6071428571428571  

julia> using SimpleWeightedGraphs

julia> triangle = SimpleWeightedGraph(3);

julia> add_edge!(triangle, 1, 2, 1);

julia> add_edge!(triangle, 2, 3, 1);

julia> add_edge!(triangle, 3, 1, 1);

julia> barbell = blockdiag(triangle, triangle);

julia> add_edge!(barbell, 1, 4, 5); # this edge has a weight of 5

julia> modularity(barbell, [1, 1, 1, 2, 2, 2])
0.045454545454545456
```
"""
function modularity(
    g::AbstractGraph,
    c::AbstractVector{<:Integer}; 
    distmx::AbstractArray{<:Number}=weights(g), 
    γ=1.0
    )
 
    m = sum([distmx[src(e), dst(e)] for e in edges(g)])
    m = is_directed(g) ? m : 2 * m

    m == 0 && return 0.
    nc = maximum(c)
    kin = zeros(Float32, nc)
    kout = zeros(Float32, nc)
    Q = 0.0
    for u in vertices(g)
        for v in neighbors(g, u)
            c1 = c[u]
            c2 = c[v]
            if c1 == c2
                Q += distmx[u,v]
            end
            kout[c1] += distmx[u,v]
            kin[c2] += distmx[u,v]
        end
    end 
    Q = Q * m
    @inbounds for i = 1:nc
        Q -= γ * kin[i] * kout[i]
    end
    return Q / m^2
end
