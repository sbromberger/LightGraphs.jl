"""
    struct Degree <: CentralityMeasure
        normalize::Bool
        degreefn::Function
    end

A struct that represents an algorithm to calculate the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
of graph `g`.

### Optional Arguments
- `normalize=true`: If true, normalize each centrality measure by ``\\frac{1}{|V|-1}``.
- `degreefn=degree`: Use another degree function ([`indegree`](@ref) or [`outdegree`](@ref) are appropriate) to
calculate the degree.

# Examples
```jldoctest
julia> using LightGraphs

julia> centrality(star_graph(4), Degree())
4-element Array{Float64,1}:
 1.0               
 0.3333333333333333
 0.3333333333333333
 0.3333333333333333

 julia> centrality(path_graph(3), Degree())
3-element Array{Float64,1}:
 0.5
 1.0
 0.5
```
"""
struct Degree <: CentralityMeasure
    normalize::Bool
    degreefn::Function
end

Degree(;normalize=true, degreefn=degree) = Degree(normalize, degreefn)

centrality(g::AbstractGraph, distmx::AbstractMatrix, alg::Degree) = _degree_centrality(g, alg.degreefn, alg.normalize)

function _degree_centrality(g::AbstractGraph, degreefn::Function, normalize=true)
    n_v = nv(g)
    c = zeros(n_v)
    for v in vertices(g)
        deg = degreefn(g, v)
        s = normalize ? (1.0 / (n_v - 1.0)) : 1.0
        c[v] = deg * s
    end
    return c
end
