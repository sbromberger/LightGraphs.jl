function independent_set(
    g::AbstractGraph{T},
    alg::RandomSubset
    ) where T <: Integer

    nvg = nv(g)
    ind_set = Vector{T}()
    sizehint!(ind_set, nvg)
    deleted = falses(nvg)

    for v in randperm(alg.rng, nvg)
        (deleted[v] || has_edge(g, v, v)) && continue

        deleted[v] = true
        push!(ind_set, v)
        deleted[neighbors(g, v)] .= true
    end

    return ind_set
end
