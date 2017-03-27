function _degree_centrality(g::AbstractGraph, gtype::Integer; normalize=true)
    n_v = nv(g)
    c = zeros(n_v)
    for v in vertices(g)
        if gtype == 0    # count both in and out degree if appropriate
            deg = is_directed(g)? outdegree(g, v) + indegree(g, v) : outdegree(g, v)
        elseif gtype == 1    # count only in degree
            deg = indegree(g, v)
        else                 # count only out degree
            deg = outdegree(g, v)
        end
        s = normalize? (1.0 / (n_v - 1.0)) : 1.0
        c[v] = deg*s
    end
    return c
end

"""
    degree_centrality(g)
    indegree_centrality(g)
    outdegree_centrality(g)

Calculate the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
of graph `g`. Return a vector representing the centrality calculated for each node in `g`.

### Optional Arguments
- `normalize=true`: If true, normalize each centrality measure by ``\frac{1}{|V|-1}``.
"""
degree_centrality(g::AbstractGraph; all...) = _degree_centrality(g, 0; all...)
indegree_centrality(g::AbstractGraph; all...) = _degree_centrality(g, 1; all...)
outdegree_centrality(g::AbstractGraph; all...) = _degree_centrality(g, 2; all...)
