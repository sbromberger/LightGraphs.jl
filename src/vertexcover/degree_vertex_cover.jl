"""
    degree_vertex_cover(g)

Obtain a vertex cover using a greedy heuristic.

### Implementation Notes
An edge is said to be covered if it has at least one end-point in the vertex cover.
Initialise the vertex cover to an empty set and iteratively choose the vertex with the most uncovered
edges.

### Performance
Runtime: O((|V|+|E|)*log(|V|))
Memory: O(|V|)
"""
function degree_vertex_cover(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg::T = nv(g)  
    cover = Vector{T}()  
    deleted = falses(nvg)
    degree_queue = PriorityQueue(Base.Order.Reverse, enumerate(degree(g)))

    while !isempty(degree_queue) && peek(degree_queue)[2] > 0
        v = dequeue!(degree_queue)

        deleted[v] = true
        push!(cover, v)
        @inbounds @simd for u in neighbors(g, v)
            if !deleted[u] 
                degree_queue[u] -= 1
            end
        end
    end

    return cover
end
