"""
    update_dominated(degree_queue, v, dominated, deleted)

Helper function used to check if a vertex is already dominated and to
update `degree_queue` if it is not.
"""
function update_dominated(
    g::AbstractGraph{T},
    degree_queue::PriorityQueue,
    v::Integer,
    dominated::Vector{Bool},
    deleted::Vector{Bool}
    ) where T <: Integer

    if !dominated[v]
        dominated[v] = true
        deleted[v] || (degree_queue[v] -= 1)
        for u in neighbors(g, v)
            deleted[u] || (degree_queue[u] -= 1)
        end
    end
end

"""
    degree_dominating_set(g)

Greedy Hueristic to solve Minimum Dominating Set.
### Implementation Notes
Initially, all vertices are undominated.
Itertively chooses the vertex that would dominate the most undominated vertices.
### Performance
O( (|V|+|E|)*log(|V|) )
"""
function degree_dominating_set(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg::T = nv(g)  
    dom_set = Vector{T}()  
    deleted = zeros(Bool, nvg)
    dominated = zeros(Bool, nvg)
    degree_queue = PriorityQueue(Base.Order.Reverse, zip(collect(1:nv(g)), broadcast(+, degree(g), 1)))

    while !isempty(degree_queue) && peek(degree_queue)[2] > 0
        v = dequeue_pair!(degree_queue)[1]
        deleted[v] = true
        push!(dom_set, v)

        update_dominated(g, degree_queue, v, dominated, deleted)
        for u in neighbors(g, v)
    		update_dominated(g, degree_queue, u, dominated, deleted)
    	end
    end
    return dom_set
end
