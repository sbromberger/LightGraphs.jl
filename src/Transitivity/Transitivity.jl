module Transitivity

using LightGraphs
using SimpleTraits
using LightGraphs.SimpleGraphs
using LightGraphs.Traversals

"""
    transitive_closure!(g, selflooped=false)

Compute the transitive closure of a directed graph, using DFS.
If `selflooped` is true, add self loops to the graph.

### Performance
Time complexity is ``\\mathcal{O}(|E||V|)``.

### Implementation Notes
This version of the function modifies the original graph.
"""
function transitive_closure! end
@traitfn function transitive_closure!(g::::IsDirected, selflooped=false)
    scc = strongly_connected_components(g)
    cg = condensation(g, scc)
    tp = reverse(topological_sort(cg, DFS()))
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
    transitive_closure(g, selflooped=false)

Compute the transitive closure of a directed graph, using DFS.
Return a graph representing the transitive closure. If `selflooped`
is `true`, add self loops to the graph.

### Performance
Time complexity is ``\\mathcal{O}(|E||V|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> barbell = blockdiag(complete_digraph(3), complete_digraph(3));

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

julia> collect(edges(transitive_closure(barbell)))
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
function transitive_closure(g::DiGraph, selflooped = false)
    copyg = copy(g)
    return transitive_closure!(copyg, selflooped)
end

"""
    transitive_reduction(g; selflooped=false)

Compute the transitive reduction of  a directed graph. If the graph contains
cycles, each strongly connected component is replaced by a directed cycle and
the transitive reduction is calculated on the condensation graph connecting the
components. If `selflooped` is true, self loops on strongly connected components
of size one will be preserved.

### Performance
Time complexity is ``\\mathcal{O}(|V||E|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> barbell = blockdiag(complete_digraph(3), complete_digraph(3));

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

julia> collect(edges(transitive_reduction(barbell)))
7-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 4
 Edge 2 => 3
 Edge 3 => 1
 Edge 4 => 5
 Edge 5 => 6
 Edge 6 => 4
```
"""
function transitive_reduction end
@traitfn function transitive_reduction(g::::IsDirected; selflooped::Bool=false)
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

export transitive_closure, transitive_reduction

end # module
