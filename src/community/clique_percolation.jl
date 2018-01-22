##############################################################################################

# Finding overlapping communities of an undirected graph using the clique percolation method #

##############################################################################################

"""
     clique_percolation(g,k=3)
     community detection using the clique percolation method.
     # reference 
     -[Palla G, Derenyi I, Farkas I J, et al.] (https://www.nature.com/articles/nature03607)
"""

function clique_percolation(g::SimpleGraph; k=3)
  kcliques = filter(x->length(x)>=k, maximal_cliques(g))
  nc = length(kcliques)
  # graph with nodes represent k-cliques
  h = Graph(nc)
  # vector for counting common nodes between two cliques efficiently
  x = fill(false, nv(g))
  for i = 1:nc
    for u in kcliques[i]
      x[u] = true
    end
    for j = i+1:nc
        common_nodes = 0
        for v in kcliques[j]
            if x[v]
                common_nodes += 1
            end
        end
        if common_nodes >= k-1
            add_edge!(h, i, j)
        end
    end
    # reset status
    for u in kcliques[i]
      x[u] = false
    end
  end
  components = connected_components(h)
  communities = [IntSet() for i=1:length(components)]
  for (i,component) in enumerate(components), u in component, v in kcliques[u]
    push!(communities[i], v)
   end
   communities
end
