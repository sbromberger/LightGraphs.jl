function _degree_centrality(g::AbstractGeneralGraph, gtype::Integer; normalize=true)
   n_v = nv(g)
   c = zeros(n_v)
   for v in 1:n_v
       if gtype == 0    # count both in and out degree if appropriate
           deg = outdegree(g, v) + (typeof(g) == DiGraph? indegree(g, v) : 0.0)
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

degree_centrality(g::AbstractGeneralGraph; all...) = _degree_centrality(g, 0; all...)
indegree_centrality(g::AbstractGeneralGraph; all...) = _degree_centrality(g, 1; all...)
outdegree_centrality(g::AbstractGeneralGraph; all...) = _degree_centrality(g, 2; all...)
