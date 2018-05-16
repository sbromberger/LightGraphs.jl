"""
    degree_independent_set(g)

Greedy Hueristic to solve Maximum Independent Set.
### Implementation Notes
Itertively chooses the vertex with the smallest degree for the independent set.
### Performance
O( (|V|+|E|)*log(|V|) )
"""
function degree_independent_set(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg::T = nv(g)  
    ind_set = Vector{T}()  
    deleted = zeros(Bool, nvg)
    degree_queue = PriorityQueue(zip(collect(1:nv(g)), degree(g)))

    while !isempty(degree_queue)
        v = dequeue_pair!(degree_queue)[1]
        deleted[v] && continue
        deleted[v] = true
        push!(ind_set, v)

        for u in neighbors(g, v)
        	deleted[u] && continue
        	deleted[u] = true
        	for w in neighbors(g, u)
        		deleted[w] || (degree_queue[w] -= 1)
        	end
        end
    end
    return ind_set
end
