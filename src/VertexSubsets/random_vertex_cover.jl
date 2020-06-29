function vertex_cover(
    g::AbstractGraph{T},
    alg::RandomSubset
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
