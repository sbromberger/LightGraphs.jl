"""
    degree_vertex_cover(g)

Greedy Hueristic to solve Minimum Vertex Cover.
### Implementation Notes
Itertively chooses the vertex with the largest degree into the covering.
### Performance
O( (|V|+|E|)*log(|V|) )
"""
function degree_vertex_cover(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg::T = nv(g)  
    cover = Vector{T}()  
    deleted = zeros(Bool, nvg)
    degree_queue = PriorityQueue(Base.Order.Reverse, zip(collect(1:nv(g)), degree(g)))

    while !isempty(degree_queue) && peek(degree_queue)[2] > 0
        max_degree_entry = dequeue_pair!(degree_queue)
        v = max_degree_entry[1]

	deleted[v] = true
	push!(cover, v)
        for u in neighbors(g, v)
            deleted[u] || (degree_queue[u] -= 1)
        end
    end

    return cover
end
