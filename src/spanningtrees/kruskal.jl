"""
    kruskal_mst(g, distmx=weights(g); minimize=true)

Return a vector of edges representing the minimum (by default) spanning tree of a connected, 
undirected graph `g` with optional distance matrix `distmx` using [Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm).

### Optional Arguments
- `minimize=true`: if set to `false`, calculate the maximum spanning tree.
"""
function kruskal_mst end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function kruskal_mst(g::AG::(!IsDirected),
    distmx::AbstractMatrix{T}=weights(g); minimize=true) where {T <: Real, AG <: AbstractGraph}

    connected_vs = IntDisjointSets(nv(g))

    mst = Vector{edgetype(g)}()
    sizehint!(mst, nv(g) - 1)

    weights = Vector{T}(undef, ne(g))
    edge_list = Vector{edgetype(g)}(undef, ne(g))

    if typeof(g) <: SimpleGraph
        i = 1
        @inbounds for u in vertices(g)
            for v in neighbors(g, u)
                v < u && continue
                edge_list[i] = LightGraphs.SimpleGraphs.SimpleEdge(u, v)
                weights[i] = distmx[u, v]
                i += 1
            end
        end
    else
        @inbounds for (i, e) in enumerate(edges(g))
            edge_list[i] = e
            weights[i] = distmx[src(e), dst(e)]
            i += 1
        end
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
