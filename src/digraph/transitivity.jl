"""
    transitiveclosure!(g, selflooped=false)

Compute the transitive closure of a directed graph, using the Floyd-Warshall
algorithm. If `selflooped` is true, add self loops to the graph.

### Performance
Time complexity is \\mathcal{O}(|V|^3).

### Implementation Notes
This version of the function modifies the original graph.
"""
function transitiveclosure! end
@traitfn function transitiveclosure!(g::::IsDirected, selflooped=false)
    for k in vertices(g)
        for i in inneighbors(g, k), j in outneighbors(g, k)
            i == k && continue
            j == k && continue
            if i == j && !selflooped
                continue
            end
            add_edge!(g, i, j)      
        end
    end
    return g
end

"""
    transitiveclosure(g, selflooped=false)

Compute the transitive closure of a directed graph, using the Floyd-Warshall
algorithm. Return a graph representing the transitive closure. If `selflooped`
is `true`, add self loops to the graph.

### Performance
Time complexity is \\mathcal{O}(|V|^3).
"""
function transitiveclosure(g::DiGraph, selflooped = false)
    copyg = copy(g)
    return transitiveclosure!(copyg, selflooped)
end
