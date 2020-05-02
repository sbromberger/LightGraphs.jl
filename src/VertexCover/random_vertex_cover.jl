"""
    struct RandomVertexCover <:VertexCovering 

A struct describing an algorithm that performs [Approximate Minimum Vertex Cover](https://en.wikipedia.org/wiki/Vertex_cover#Approximate_evaluation) once.

### Optional Arguments
- `rng<:AbstractRNG`: if not supplied, `GLOBAL_RNG` will be used as a default.

### Performance
- Memory: O(|E|)
- Runtime: O(|V|+|E|)
- Approximation Factor: 2
"""
struct RandomVertexCover{R<:AbstractRNG} <:VertexCovering
    rng::R
end
RandomVertexCover(;rng=GLOBAL_RNG) = RandomVertexCover(rng)

function vertex_cover(
    g::AbstractGraph{T},
    alg::RandomVertexCover
    ) where T <: Integer

    (ne(g) > 0) || return Vector{T}() #Shuffle raises error
    nvg = nv(g)
    in_cover = falses(nvg)
    length_cover = 0

    es = collect(edges(g))
    shuffle!(alg.rng, es)
    @inbounds for e in es
        u = src(e)
        v = dst(e)
        if !(in_cover[u] || in_cover[v])
            in_cover[u] = in_cover[v] = true
            length_cover += (v != u ? 2 : 1)
        end
    end
    return LightGraphs.findall!(in_cover, Vector{T}(undef, length_cover))
end
