"""
    struct DegreeSubset <: VertexSubset

A struct representing a degree-based greedy algorithm to calculate the vertex subset.
"""
struct DegreeSubset <: VertexSubset end

function vertex_cover(g::AbstractGraph{T}, ::DegreeSubset) where {T <: Integer}
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
