function _degree_centrality(g::AbstractGraph, gtype::Integer; normalize=true)
    n_v = nv(g)
    c = zeros(n_v)
    for v in vertices(g)
        if gtype == 0    # count both in and out degree if appropriate
            deg = is_directed(g) ? outdegree(g, v) + indegree(g, v) : outdegree(g, v)
        elseif gtype == 1    # count only in degree
            deg = indegree(g, v)
        else                 # count only out degree
            deg = outdegree(g, v)
        end
        s = normalize ? (1.0 / (n_v - 1.0)) : 1.0
        c[v] = deg * s
    end
    return c
end

"""
    centrality(g, alg=Degree())
    centrality(g, alg=InDegree())
    centrality(g, alg=OutDegree())

Calculate the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
of graph `g`. Return a vector representing the centrality calculated for each node in `g`.

### Optional Arguments
- `normalize=true`: If true, normalize each centrality measure by ``\\frac{1}{|V|-1}``.

# Examples
```jldoctest
julia> using LightGraphs

julia> degree_centrality(star_graph(4))
4-element Array{Float64,1}:
 1.0
 0.3333333333333333
 0.3333333333333333
 0.3333333333333333

julia> degree_centrality(path_graph(3))
3-element Array{Float64,1}:
 0.5
 1.0
 0.5
```
"""
struct Degree <: CentralityAlgorithm
struct InDegree <: CentralityAlgorithm
struct OutDegree <: CentralityAlgorithm

centrality(g::AbstractGraph; alg::Degree, all...) = _degree_centrality(g, 0; all...)
centrality(g::AbstractGraph; alg::InDegree, all...) = _degree_centrality(g, 1; all...)
centrality(g::AbstractGraph; alg::OutDegree, all...) = _degree_centrality(g, 2; all...)
