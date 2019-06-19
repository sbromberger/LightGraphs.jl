"""
    ```transitiveclosure!(g::::(!IsDirected), selflooped = false)```
Compute the transitive closure of an undirected graph.
If `selflooped` is true, add self loops to the graph.
If `selflooped` is false and there are already self loops in the graph, removes self loops.

### Implementation Notes
This version of the function modifies the original graph.
"""
function transitiveclosure! end
@traitfn function transitiveclosure!(g::::(!IsDirected), selflooped = false)
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
    ```transitiveclosure(g::Graph, selflooped = false)```
Compute the transitive closure of an undirected graph.
If `selflooped` is true, add self loops to the graph.
"""
function transitiveclosure(g::Graph, selflooped = false)
    copyg = copy(g)
    return transitiveclosure!(copyg, selflooped)
end


"""
    ```transitiveclosure!(g::::IsDirected, selflooped=false)```

Compute the transitive closure of a directed graph, using DFS.
If `selflooped` is true, add self loops to the graph.
If `selflooped` is false and there are already self loops in the graph, removes self loops.

### Performance
Time complexity is ``\\mathcal{O}(|E||V|)``.

### Implementation Notes
This version of the function modifies the original graph.
"""
function transitiveclosure! end
@traitfn function transitiveclosure!(g::::IsDirected, selflooped=false)
    scc = strongly_connected_components(g)
    cg = condensation(g, scc)
    tp = reverse(topological_sort_by_dfs(cg))
    sr = [Vector{eltype(cg)}() for _ in vertices(cg)]

    x = selflooped ? 0 : 1
    for comp in scc
        for j in 1:(length(comp)-x)
            for k in (j+x):length(comp)
                add_edge!(g, comp[j], comp[k])
                add_edge!(g, comp[k], comp[j])
            end
        end
    end
    for u in tp
        for v in outneighbors(cg, u)
            union!(sr[u], sr[v], [v])
        end
    end
    for i in vertices(cg)
        for u in scc[i]
            for j in sr[i]
                for v in scc[j]
                    add_edge!(g, u, v)
                end
            end
        end
    end
    return g
end

"""
    transitiveclosure(g, selflooped=false)

Compute the transitive closure of a directed graph, using DFS.
Return a graph representing the transitive closure. If `selflooped`
is `true`, add self loops to the graph.

### Performance
Time complexity is ``\\mathcal{O}(|E||V|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> barbell = blockdiag(CompleteDiGraph(3), CompleteDiGraph(3));

julia> add_edge!(barbell, 1, 4);

julia> collect(edges(barbell))
13-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 1 => 4
 Edge 2 => 1
 Edge 2 => 3
 Edge 3 => 1
 Edge 3 => 2
 Edge 4 => 5
 Edge 4 => 6
 Edge 5 => 4
 Edge 5 => 6
 Edge 6 => 4
 Edge 6 => 5

julia> collect(edges(transitiveclosure(barbell)))
21-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 1 => 4
 Edge 1 => 5
 Edge 1 => 6
 Edge 2 => 1
 Edge 2 => 3
 Edge 2 => 4
 Edge 2 => 5
 Edge 2 => 6
 Edge 3 => 1
 Edge 3 => 2
 Edge 3 => 4
 Edge 3 => 5
 Edge 3 => 6
 Edge 4 => 5
 Edge 4 => 6
 Edge 5 => 4
 Edge 5 => 6
 Edge 6 => 4
 Edge 6 => 5
```
"""
function transitiveclosure(g::DiGraph, selflooped = false)
    copyg = copy(g)
    return transitiveclosure!(copyg, selflooped)
end


