"""
    random_minimal_dominating_set(g)

Find a set of vertices that are dominating (all vertices in `g` are either adjacent to a vertex 
in the set or is a vertex in the set) and it is not possible to delete a vertex from the set 
without sacrificing the dominating property.

### Implementation Notes
Initially, every vertex is in the dominating set.
In some random order, we check if the removal of a vertex from the dominating set will no longer make the
vertex a dominating set. If no, the vertex is removed from the dominating set.

### Performance
Runtime: O(|V|+|E|)
Memory: O(|V|)
"""    
function random_minimal_dominating_set(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg = nv(g)  
    is_dom = trues(nvg)  
    dom_degree = degree(g)
    dom_size = nvg

    for v in shuffle(vertices(g))
    	(dom_degree[v] == 0) && continue
    	safe = true
    	for u in neighbors(g, v)
        	@inbounds if !is_dom[u] && dom_degree[u] <= 1
        		safe = false
        		break
        	end
        end
        safe || continue
        is_dom[v] = false
        dom_size -= 1
        dom_degree[neighbors(g, v)] .-= 1
    end

    return [v for v in vertices(g) if is_dom[v]]
end
