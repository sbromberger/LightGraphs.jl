"""
    kruskal_mst(g, distmx=weights(g); minimize=true)

Return a vector of edges representing the minimum (by default) spanning tree of a connected,
undirected graph `g` with optional distance matrix `distmx` using [Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm).

### Optional Arguments
- `minimize=true`: if set to `false`, calculate the maximum spanning tree.
"""
function kruskal_mst end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function kruskal_mst(g::G,
                              distmx::AbstractMatrix{T}=weights(g); minimize=true) where {T <: Real, G <: AbstractGraph; HasContiguousVertices{G}, !IsDirected{G}}

    connected_vs = IntDisjointSets(nv(g))
    mst = Vector{edgetype(g)}()
    sizehint!(mst, nv(g) - 1)

    weights = Vector{T}()
    sizehint!(weights, ne(g))
    edge_list = collect(edges(g))
    for e in edge_list
      push!(weights, distmx[src(e), dst(e)])
    end

    for e in edge_list[sortperm(weights; rev=!minimize)]
        if !in_same_set(connected_vs, src(e), dst(e))
            union!(connected_vs, src(e), dst(e))
            push!(mst, e)
            (length(mst) >= nv(g) - 1) && break
        end
    end
    return mst
end
