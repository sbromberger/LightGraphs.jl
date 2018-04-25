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
            ((!selflooped && i == j) || i == k || j == k) && continue
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

"""
    transitivereduction(g; selflooped=false)

Compute the transitive reduction of  a directed graph. If the graph contains
cycles, each strongly connected component is replaced by a directed cycle and
the transitive reduction is calculated on the condensation graph connecting the
components. If `selflooped` is true, self loops on strongly connected components
of size one will be preserved.

### Performance
Time complexity is \\mathcal{O}(|V||E|).
"""
function transitivereducion end
@traitfn function transitivereduction(g::::IsDirected; selflooped::Bool=false)
    scc = strongly_connected_components(g) 
    cg = condensation(g, scc) 

    reachable = Vector{Bool}(undef, nv(cg)) 
    visited = Vector{Bool}(undef, nv(cg))
    stack = Vector{eltype(cg)}(undef, nv(cg)) 
    resultg = SimpleDiGraph{eltype(g)}(nv(g))
    
# Calculate the transitive reduction of the acyclic condensation graph.
    @inbounds(
    for u in vertices(cg)
        fill!(reachable, false) # vertices reachable from u on a path of length >= 2
        fill!(visited, false)
        stacksize = 0
        for v in outneighbors(cg,u)
      @simd for w in outneighbors(cg, v)
                if !visited[w]
                    visited[w] = true
                    stacksize += 1
                    stack[stacksize] = w
                end
            end
        end
        while stacksize > 0
            v = stack[stacksize]
            stacksize -= 1
            reachable[v] = true
      @simd for w in outneighbors(cg, v)
                if !visited[w]
                    visited[w] = true
                    stacksize += 1
                    stack[stacksize] = w
                end
            end
        end
# Add the edges from the condensation graph to the resulting graph.
  @simd for v in outneighbors(cg,u)
            if !reachable[v]
                add_edge!(resultg, scc[u][1], scc[v][1])
            end
        end
    end)

# Replace each strongly connected component with a directed cycle.
    @inbounds(
    for component in scc
        nvc = length(component)
        if nvc == 1 
            if selflooped && has_edge(g, component[1], component[1])
                add_edge!(resultg, component[1], component[1])
            end
            continue
        end
        for i in 1:(nvc-1)
            add_edge!(resultg, component[i], component[i+1])
        end
        add_edge!(resultg, component[nvc], component[1])
    end)

    return resultg
end

