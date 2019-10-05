export MinimalDominatingSet

struct MinimalDominatingSet end

"""
    dominating_set(g, MinimalDominatingSet(); seed=-1)

Find a set of vertices that consitute a dominating set (all vertices in `g` are either adjacent to a vertex 
in the set or is a vertex in the set) and it is not possible to delete a vertex from the set 
without sacrificing the dominating property.

### Implementation Notes
Initially, every vertex is in the dominating set.
In some random order, we check if the removal of a vertex from the set will destroy the 
dominating property. If no, the vertex is removed from the dominating set.

### Performance
Runtime: ``\\mathcal{O}(|V|+|E|)``
Memory: ``\\mathcal{O}(|V|)``

### Optional Arguments
- If `seed >= 0`, a random generator is seeded with this value.
"""    
function dominating_set(
    g::AbstractGraph{T},
    alg::MinimalDominatingSet;
    seed::Int=-1
    ) where T <: Integer 

    nvg = nv(g)  
    in_dom_set = trues(nvg) 
    length_ds = Int(nvg)
    dom_degree = degree(g)
    @inbounds for v in vertices(g)
        dom_degree[v] -= (has_edge(g, v, v) ? 1 : 0)
    end

    for v in randperm(getRNG(seed), nvg)
    	(dom_degree[v] == 0) && continue #It is not adjacent to any dominating vertex
    	#Check if any vertex is depending on v to be dominated
        dependent = findfirst(u -> !in_dom_set[u] && dom_degree[u] <= 1, neighbors(g, v))

        (dependent != nothing) && continue
        in_dom_set[v] = false
        length_ds -= 1
        dom_degree[neighbors(g, v)] .-= 1
    end
    
    return LightGraphs.findall!(in_dom_set, Vector{T}(undef, length_ds))
end
