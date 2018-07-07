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
    in_cover = falses(nvg)

    @inbounds for e in shuffle(collect(edges(g)))
        if !(in_cover[e.src] || in_cover[e.dst])
            in_cover[e.src] = in_cover[e.dst] = true
            push!(cover, e.src)
            push!(cover, e.dst)
        end
    end

    return [v for v in vertices(g) if in_cover[v]]
end

"""
    parallel_random_vertex_cover(g, Reps)

Perform [`LightGraphs.random_vertex_cover`](@ref) `Reps` times in parallel 
and return the solution with the fewest vertices.
"""
parallel_random_vertex_cover(g::AbstractGraph{T}, Reps::Integer) where T <: Integer = 
parallel_generate_min_set(g, random_vertex_cover, Reps)
