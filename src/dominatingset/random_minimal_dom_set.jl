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
    in_dom_set = trues(nvg)  
    dom_degree = degree(g)
    for v in shuffle(vertices(g))
    	(dom_degree[v] == 0) && continue #It is not adjacent to any dominating vertex
    	
        safe_to_remove = true
    	for u in neighbors(g, v)
        	@inbounds if !in_dom_set[u] && dom_degree[u] <= 1
        		safe_to_remove = false
        		break
        	end
        end
        safe_to_remove || continue
        
        in_dom_set[v] = false
        dom_degree[neighbors(g, v)] .-= 1
    end

    return [v for v in vertices(g) if in_dom_set[v]]
end

"""
    parallel_random_minimal_dominating_set(g, Reps)

Perform [`LightGraphs.random_minimal_dominating_set`](@ref) `Reps` times in parallel 
and return the solution with the fewest vertices.
"""
parallel_random_minimal_dominating_set(g::AbstractGraph{T}, Reps::Integer) where T <: Integer = 
parallel_generate_min_set(g, random_minimal_dominating_set, Reps)
