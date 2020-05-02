"""
    struct DegreeVertexCover <:VertexCovering 

A struct representing an algorithm to obtain a vertex cover using a greedy heuristic.
Initializes the vertex cover to an empty set and iteratively chooses the vertex with
the most uncovered edges.

### Performance
- Memory: O(|V|)
- Runtime: O((|V|+|E|)*log(|V|))
"""
struct DegreeVertexCover <:VertexCovering end

function vertex_cover(g::AbstractGraph{T}, ::DegreeVertexCover) where {T <: Integer}
    nvg = nv(g)
    in_cover = falses(nvg)
    length_cover = 0
    degree_queue = PriorityQueue(Base.Order.Reverse, enumerate(degree(g)))

    while !isempty(degree_queue) && peek(degree_queue)[2] > 0
        v = dequeue!(degree_queue)
        in_cover[v] = true
        length_cover += 1

        @inbounds @simd for u in neighbors(g, v)
            if !in_cover[u]
                degree_queue[u] -= 1
            end
        end
    end
    return LightGraphs.findall!(in_cover, Vector{T}(undef, length_cover))
end
