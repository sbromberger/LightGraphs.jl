function independent_set(
    g::AbstractGraph{T},
    ::DegreeSubset
    ) where T <: Integer

    nvg = nv(g)
    ind_set = Vector{T}()
    sizehint!(ind_set, nvg)
    deleted = falses(nvg)
    degree_queue = PriorityQueue(enumerate(degree(g)))

    while !isempty(degree_queue)
        v = dequeue!(degree_queue)
        (deleted[v] || has_edge(g, v, v)) && continue
        deleted[v] = true
        push!(ind_set, v)

        for u in neighbors(g, v)
            deleted[u] && continue
            deleted[u] = true
            @inbounds @simd for w in neighbors(g, u)
                if !deleted[w]
                    degree_queue[w] -= 1
                end
            end
        end
    end
    return ind_set
end
