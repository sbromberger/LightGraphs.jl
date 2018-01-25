
"""
     clique_percolation(g, k=3)

Community detection using the clique percolation algorithm. Communities are potentionally overlapping.
Return a vector of vectors `c` such that `c[i]` is the set of vertices in community `i`. 
The parameter `k` defines the size of the clique to use in percolation.

### References
- [Palla G, Derenyi I, Farkas I J, et al.] (https://www.nature.com/articles/nature03607)
"""
function clique_percolation end

function clique_percolation(g::::(!IsDirected); k=3)
  kcliques = filter(x->length(x)>=k, maximal_cliques(g))
  nc = length(kcliques)
  # graph with nodes represent k-cliques
  h = Graph(nc)
  # vector for counting common nodes between two cliques efficiently
  x = falses(nv(g))
  for i = 1:nc
    x[kcliques[i]] = true
    for j = i+1:nc
        common_nodes = sum(x[kcliques[j]])
        if common_nodes >= k-1
            add_edge!(h, i, j)
        end
    end
    # reset status
    x[kcliques[i]] = false
  end
  components = connected_components(h)
  communities = [IntSet() for i=1:length(components)]
  for (i,component) in enumerate(components)    
    push!(communities[i], vcat(kcliques[component]...)...)
  end 
  return communities
end
