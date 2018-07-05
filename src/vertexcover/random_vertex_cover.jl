"""
    random_vertex_cover(g)

Find a set of vertices such that every edge in `g` has some vertex in the set as 
atleast one of its end point.

### Implementation Notes
Performs [Approximate Minimum Vertex Cover](https://en.wikipedia.org/wiki/Vertex_cover#Approximate_evaluation) once.
Returns a vector of vertices representing the vertices in the Vertex Cover.

### Performance
Runtime: O(|V|+|E|)
Memory: O(|E|)
Approximation Factor: 2
"""
function random_vertex_cover(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg::T = nv(g)  
    cover = Vector{T}()  
    seen = falses(nvg)

    @inbounds for e in shuffle(collect(edges(g)))
        if !(seen[e.src] || seen[e.dst])
            seen[e.src] = seen[e.dst] = true
            push!(cover, e.src)
            push!(cover, e.dst)
        end
    end

    return cover
end
