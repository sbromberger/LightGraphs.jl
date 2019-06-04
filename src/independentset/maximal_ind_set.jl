export MaximalIndependentSet

struct MaximalIndependentSet end

"""
    independent_set(g, MaximalIndependentSet(); rng=Random.GLOBAL_RNG)

Find a random set of vertices that are independent (no two vertices are adjacent to each other) and
it is not possible to insert a vertex into the set without sacrificing the independence property.

### Implementation Notes
Performs [Approximate Maximum Independent Set](https://en.wikipedia.org/wiki/Maximal_independent_set#Sequential_algorithm) once.
Returns a vector of vertices representing the vertices in the independent set.

### Performance
Runtime: O(|V|+|E|)
Memory: O(|V|)
Approximation Factor: maximum(degree(g))+1

### Optional Arguments
- A random number generator `rng`, defaulting to `Random.GLOBAL_RNG`.
"""
function independent_set(
    g::AbstractGraph{T},
    alg::MaximalIndependentSet;
    rng::AbstractRNG=Random.GLOBAL_RNG
    ) where T <: Integer

    nvg = nv(g)
    ind_set = Vector{T}()
    sizehint!(ind_set, nvg)
    deleted = falses(nvg)

    for v in randperm(rng, nvg)
        (deleted[v] || has_edge(g, v, v)) && continue

        deleted[v] = true
        push!(ind_set, v)
        deleted[neighbors(g, v)] .= true
    end

    return ind_set
end
