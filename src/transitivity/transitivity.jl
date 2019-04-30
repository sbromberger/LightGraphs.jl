"""
    ```transitiveclosure!(g::SimpleGraph, selflooped = false)```
Compute the transitive closure of an undirected graph.
If `selflooped` is true, add self loops to the graph.

### Implementation Notes
This version of the function modifies the original graph.
"""
function transitiveclosure!(g::Graph, selflooped = false)
    cc = connected_components(g)
    x = selflooped ? 0 : 1
    for comp in cc
        for i in 1:(length(comp) - x)
            for j in (i+x):length(comp)
                add_edge!(g, comp[i], comp[j])
            end
        end
    end
    return g
end 

"""
    ```transitiveclosure(g::SimpleGraph, selflooped = false)```
Compute the transitive closure of an undirected graph.
If `selflooped` is true, add self loops to the graph.
"""
function transitiveclosure(g::Graph; selflooped = false)
    copyg = copy(g)
    return transitiveclosure!(copyg, selflooped)
end