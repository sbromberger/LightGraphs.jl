"""
```transitiveclosure!(dg::DiGraph, selflooped = false)```

Compute the transitive closure of a directed graph, using the Floyd-Warshall
algorithm.

Version of the function that modifies the original graph.

Note: This is an O(V^3) algorithm.

# Arguments
* `dg`: the directed graph on which the transitive closure is computed.
* `selflooped`: whether self loop should be added to the directed graph,
default to `false`.
"""
function transitiveclosure!(dg::DiGraph, selflooped = false)
    for k in vertices(dg)
        for i in vertices(dg)
            if i == k
                continue
            end
            for j in vertices(dg)
                if j == k
                    continue
                end
                if (has_edge(dg, i, k) && has_edge(dg, k, j))
                    if ( i != j || selflooped )
                        add_edge!(dg, i, j)
                    end
                end
            end
        end
    end
    return dg
end

"""
```transitiveclosure(dg::DiGraph, selflooped = false)```

Compute the transitive closure of a directed graph, using the Floyd-Warshall
algorithm.

Version of the function that does not modify the original graph.

# Arguments
* `dg`: the directed graph on which the transitive closure is computed.
* `selflooped`: whether self loop should be added to the directed graph,
default to `false`.
"""
function transitiveclosure(dg::DiGraph, selflooped = false)
    copydg = copy(dg)
    return transitiveclosure!(copydg, selflooped)
end
