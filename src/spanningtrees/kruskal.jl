function kruskal_mst end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function kruskal_mst(
    g::AG::(!IsDirected),
    distmx::AbstractMatrix{T} = weights(g)
) where {T<:Real, U, AG<:AbstractGraph{U}}

    connected_vs = DataStructures.IntDisjointSets(nv(g))

    mst = Vector{Edge}()
    sizehint!(mst, nv(g) - 1)

    weights = Vector{T}()
    sizehint!(weights, ne(g))
    edge_list = collect(edges(g))
    for e in edge_list
        push!(weights, distmx[src(e), dst(e)])
    end

    for e in edge_list[sortperm(weights)]
        if !DataStructures.in_same_set(connected_vs, e.src, e.dst)
            DataStructures.union!(connected_vs, e.src, e.dst)
            push!(mst, e)
            if length(mst) >= nv(g) - 1
                break
            end
        end
    end

    return mst
end
