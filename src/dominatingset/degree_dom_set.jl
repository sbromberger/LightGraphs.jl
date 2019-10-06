export DegreeDominatingSet

struct DegreeDominatingSet end

"""
    update_dominated!(degree_queue, v, dominated, in_dom_set)

Check if a vertex is already dominated.
If not, make it dominated and update `degree_queue` by decreasing
the priority of the vertices adjacent to `v` by 1.
"""
function update_dominated!(
    g::AbstractGraph{T},
    degree_queue::PriorityQueue,
    v::Integer,
    dominated::BitArray{1},
    in_dom_set::BitArray{1}
    ) where T <: Integer

    @inbounds if !dominated[v]
        dominated[v] = true
        if !in_dom_set[v] 
            degree_queue[v] -= 1
        end
        @inbounds @simd for u in neighbors(g, v)
            if !in_dom_set[u] 
                degree_queue[u] -= ifelse(in_dom_set[u], 0, 1)
            end
        end
    end
end

"""
    dominating_set(g, DegreeDominatingSet())

Obtain a [dominating set](https://en.wikipedia.org/wiki/Dominating_set) using a greedy heuristic.

### Implementation Notes
A vertex is said to be dominated if it is in the dominating set or adjacent to a vertex 
in the dominating set.
Initialise the dominating set to an empty set and iteratively choose the vertex that would 
dominate the most undominated vertices.

### Performance
Runtime: ``\\mathcal{O}((|V|+|E|)*log(|V|))``
Memory: ``\\mathcal{O}(|V|)``
Approximation Factor: `ln(maximum(degree(g)))+2`
"""
function dominating_set(
    g::AbstractGraph{T},
    alg::DegreeDominatingSet
    ) where T <: Integer 

    nvg = nv(g)  
    in_dom_set = falses(nvg)
    dominated = falses(nvg)
    degree_queue = PriorityQueue(Base.Order.Reverse, enumerate(degree(g) .+ 1))
    length_ds = 0

    while !isempty(degree_queue) && peek(degree_queue)[2] > 0
        v = dequeue!(degree_queue)
        in_dom_set[v] = true
        length_ds += 1

        update_dominated!(g, degree_queue, v, dominated, in_dom_set)
        for u in neighbors(g, v)
            update_dominated!(g, degree_queue, u, dominated, in_dom_set)
        end
    end
    
    return LightGraphs.findall!(in_dom_set, Vector{T}(undef, length_ds))
end
