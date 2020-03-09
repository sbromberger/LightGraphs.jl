export DegreeIndependentSet

struct DegreeIndependentSet end

"""
    independent_set(g, DegreeIndependentSet())

Obtain an [independent set](https://en.wikipedia.org/wiki/Independent_set_(graph_theory)) of
`g` using a greedy heuristic based on the degree of the vertices.

### Implementation Notes
A vertex is said to be valid if it is not in the independent set or adjacent to any vertex
in the independent set.
Initilalise the independent set to an empty set and iteratively choose the vertex that is
adjacent to the fewest valid vertices in the independent set until all vertices are invalid.

### Performance
Runtime: O((|V|+|E|)*log(|V|))
Memory: O(|V|)
"""
function independent_set(
    g::AbstractGraph{T},
    alg::DegreeIndependentSet
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
