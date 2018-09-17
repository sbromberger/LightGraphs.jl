export DegreeVertexCover

struct DegreeVertexCover end

"""
    vertex_cover(g, DegreeVertexCover())

Obtain a vertex cover using a greedy heuristic.

### Implementation Notes
An edge is said to be covered if it has at least one end-point in the vertex cover.
Initialise the vertex cover to an empty set and iteratively choose the vertex with the most uncovered
edges.

### Performance
Runtime: O((|V|+|E|)*log(|V|))
Memory: O(|V|)
"""
function vertex_cover(
    g::AbstractGraph{T},
    alg::DegreeVertexCover
    ) where T <: Integer 

    nvg = nv(g)    
    in_cover = falses(nvg)
    degree_queue = PriorityQueue(Base.Order.Reverse, enumerate(degree(g)))

    while !isempty(degree_queue) && peek(degree_queue)[2] > 0
        v = dequeue!(degree_queue)
        in_cover[v] = true

        @inbounds @simd for u in neighbors(g, v)
            if !in_cover[u] 
                degree_queue[u] -= 1
            end
        end
    end

    return [v for v in vertices(g) if in_cover[v]]
end
