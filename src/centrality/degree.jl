function _degree_centrality(g::AbstractGraph, gtype::Integer; normalize=true)
    n_v = nv(g)
    c = zeros(n_v)
    for v in vertices(g)
        if gtype == 0    # count both in and out degree if appropriate
            deg = is_directed(g) ? out_degree(g, v) + in_degree(g, v) : out_degree(g, v)
        elseif gtype == 1    # count only in degree
            deg = in_degree(g, v)
        else                 # count only out degree
            deg = out_degree(g, v)
        end
        s = normalize ? (1.0 / (n_v - 1.0)) : 1.0
        c[v] = deg * s
    end
    return c
end

"""
    degree_centrality(g)
    in_degree_centrality(g)
    out_degree_centrality(g)

Calculate the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
of graph `g`. Return a vector representing the centrality calculated for each node in `g`.

### Optional Arguments
- `normalize=true`: If true, normalize each centrality measure by ``\\frac{1}{|V|-1}``.
"""
degree_centrality(g::AbstractGraph; all...) = _degree_centrality(g, 0; all...)
in_degree_centrality(g::AbstractGraph; all...) = _degree_centrality(g, 1; all...)
out_degree_centrality(g::AbstractGraph; all...) = _degree_centrality(g, 2; all...)
