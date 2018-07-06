"""
    random_maximal_independent_set(g)

Find a set of vertices that are independent (no two vertices are adjacent to each other) and 
it is not possible to insert a vertex into the set without sacrificing the independence property.

### Implementation Notes
Performs [Approximate Maximum Independent Set](https://en.wikipedia.org/wiki/Maximal_independent_set#Sequential_algorithm) once.
Returns a vector of vertices representing the vertices in the independent set.

### Performance
Runtime: O(|V|+|E|)
Memory: O(|V|)
Approximation Factor: max(degree(g))+1
"""
function random_maximal_independent_set(
    g::AbstractGraph{T}
    ) where T <: Integer 
  
    ind_set = Vector{T}()
    sizehint!(ind_set, nv(g))  
    deleted = falses(nv(g))

    for v in shuffle(vertices(g))
        deleted[v] && continue

        deleted[v] = true
        push!(ind_set, v)
        deleted[neighbors(g, v)] .= true
    end

    return ind_set
end
