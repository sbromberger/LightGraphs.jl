export RandomVertexCover

struct RandomVertexCover end

"""
    vertex_cover(g, RandomVertexCover(); seed=-1)

Find a set of vertices such that every edge in `g` has some vertex in the set as
atleast one of its end point.

### Implementation Notes
Performs [Approximate Minimum Vertex Cover](https://en.wikipedia.org/wiki/Vertex_cover#Approximate_evaluation) once.
Returns a vector of vertices representing the vertices in the Vertex Cover.

### Performance
Runtime: O(|V|+|E|)
Memory: O(|E|)
Approximation Factor: 2

### Optional Arguments
- If `seed >= 0`, a random generator is seeded with this value.
"""
function vertex_cover(
    g::AbstractGraph{T},
    alg::RandomVertexCover;
    seed::Int = -1,
) where {T<:Integer}

    (ne(g) > 0) || return Vector{T}() #Shuffle raises error
    nvg = nv(g)
    in_cover = falses(nvg)
    length_cover = 0

    @inbounds for e in shuffle(getRNG(seed), collect(edges(g)))
        u = src(e)
        v = dst(e)
        if !(in_cover[u] || in_cover[v])
            in_cover[u] = in_cover[v] = true
            length_cover += (v != u ? 2 : 1)
        end
    end

    return LightGraphs.findall!(in_cover, Vector{T}(undef, length_cover))
end
