"""
    update_dominated(degree_queue, v, dominated, deleted)

Check if a vertex is already dominated.
If not, make it dominated and update `degree_queue` by decreasing
the priority of the vertices adjacent to `v` by 1.
"""
function update_dominated(
    g::AbstractGraph{T},
    degree_queue::PriorityQueue,
    v::Integer,
    dominated::BitArray{1},
    deleted::BitArray{1}
    ) where T <: Integer

    @inbounds if !dominated[v]
        dominated[v] = true
        if !deleted[v] 
            degree_queue[v] -= 1
        end
        @inbounds @simd for u in neighbors(g, v)
            if !deleted[u] 
                degree_queue[u] -= 1
            end
        end
    end
end

"""
    degree_dominating_set(g)

Obtain a [dominating set](https://en.wikipedia.org/wiki/Dominating_set) using a greedy heuristic.

### Implementation Notes
A vertex is said to be dominated if it is in the dominating set or adjacent to a vertex in the
dominating set.
Initialise the dominating set to an empty set and iteratively choose the vertex that would 
dominate the most undominated verteices.

### Performance
Runtime: O( (|V|+|E|)*log(|V|) )
Memory: O(|V|)
"""
function degree_dominating_set(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg = nv(g)  
    dom_set = Vector{T}()  
    deleted = falses(nvg)
    dominated = falses(nvg)
    degree_queue = PriorityQueue(Base.Order.Reverse, enumerate(degree(g) .+ 1))

    while !isempty(degree_queue) && peek(degree_queue)[2] > 0
        v = dequeue!(degree_queue)
        deleted[v] = true
        push!(dom_set, v)

        update_dominated(g, degree_queue, v, dominated, deleted)
        for u in neighbors(g, v)
            update_dominated(g, degree_queue, u, dominated, deleted)
        end
    end
    return dom_set
end
