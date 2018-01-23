@doc_str """
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
        for i in vertices(g)
            i == k && continue
            for j in vertices(g)
                j == k && continue
                if (has_edge(g, i, k) && has_edge(g, k, j))
                    if (i != j || selflooped)
                        add_edge!(g, i, j)
                    end
                end
            end
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
