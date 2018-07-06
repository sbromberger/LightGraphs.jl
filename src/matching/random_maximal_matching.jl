"""
    random_maximal_matching(g)

Find a set of edges that constitute a matching (no two edges have a common end point) and 
it is not possible to insert an edge into the set without sacrificing the matching property.

### Implementation Notes
Performs [Approximate Maximum Matching](https://en.wikipedia.org/wiki/Vertex_matching#Approximate_evaluation) once.
Returns a vector of edges representing the edges in the Matching.

### Performance
Runtime: O(|V|+|E|)
Memory: O(|E|)
Approximation Factor: 2
"""
function random_maximal_matching(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg = nv(g)  
    matching = Vector{Edge{T}}()
    sizehint!(matching, div(nvg, 2))  
    seen = falses(nvg)

    @inbounds for e in shuffle(collect(edges(g)))
        if !(seen[e.src] || seen[e.dst])
            seen[e.src] = seen[e.dst] = true
            push!(matching, e)
        end
    end
    return matching
end
