"""
    struct CliquePercolation <: CommunityDetectionAlgorithm

A struct representing the clique percolation algorithm for community detection.
Communities are potentionally overlapping.


### Optional Parameters
- `k::Int`: defines the size of the clique to use in percolation (default `3`).

### Implementation Notes
Community detection using CliquePercolation is only defined for undirected graphs.

### References
- [Palla G, Derenyi I, Farkas I J, et al.] (https://www.nature.com/articles/nature03607)

# Examples
```jldoctest
julia> using LightGraphs

julia> communities(clique_graph(3, 2), CliquePercolation())
2-element Array{BitSet,1}:
 BitSet([4, 5, 6])
 BitSet([1, 2, 3])

julia> communities(clique_graph(3, 2), CliquePercolation(k=2))
1-element Array{BitSet,1}:
 BitSet([1, 2, 3, 4, 5, 6])

julia> communities(clique_graph(3, 2), CliquePercolation(k=4))
0-element Array{BitSet,1}
```
"""
struct CliquePercolation <: CommunityDetectionAlgorithm
    k::Int
end

CliquePercolation(;k=3) = CliquePercolation(k)


@traitfn function communities(g::::(!IsDirected), alg::CliquePercolation)
  kcliques = filter(x->length(x)>=alg.k, maximal_cliques(g))
  nc = length(kcliques)
  # graph with nodes represent k-cliques
  h = SimpleGraph(nc)
  # vector for counting common nodes between two cliques efficiently
  x = falses(nv(g))
  for i = 1:nc
    x[kcliques[i]] .= true
    for j = i+1:nc
        if sum(x[kcliques[j]]) >= alg.k-1 
            add_edge!(h, i, j)
        end
    end
    # reset status
    x[kcliques[i]] .= false
  end
  components = Connectivity.connected_components(h)
  comms = [BitSet() for i=1:length(components)]
  for (i,component) in enumerate(components)
    push!(comms[i], vcat(kcliques[component]...)...)
  end
  return comms
end
