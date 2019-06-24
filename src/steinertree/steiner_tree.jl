"""
    filter_non_term_leaves!(g, term_vert)

Remove edges of `g` so that all non-isolated leaves of `g` are in the set `term_vert`
"""
function filter_non_term_leaves!(
    g::AbstractGraph{T},
    term_vert::Vector{<:Integer}
    ) where T<:Integer

    is_term = falses(nv(g))
    is_term[term_vert] .= true
    leaves = [v for v in vertices(g) if degree(g, v) == 1 && !is_term[v]]

    while !isempty(leaves)
        leaf = pop!(leaves)
        for v in neighbors(g, leaf)
            rem_edge!(g, v, leaf)
            if degree(g, v) == 1 && !is_term[v]
                push!(leaves, v)
            end
        end
    end

    return g
end

"""
	steiner_tree(g, term_vert, distmx=weights(g))

Return an approximately minimum steiner tree of connected, undirected graph `g` with positive edge 
weights represented by `distmx` using [Approximate Steiner Tree](https://en.wikipedia.org/wiki/Steiner_tree_problem#Approximating_the_Steiner_tree). 
The minimum steiner tree problem involves finding a subset of edges in `g` of minimum weight such
that all the vertices in `term_vert` are connected.

`t = length(term_vert)`.

### Performance
Runtime: O(t*(t*log(t)+|E|*log(|V| ))
Memory: O(t*|V|)
Approximation Factor: 2-2/t
"""
function steiner_tree end

@traitfn function steiner_tree(
    g::AG::(!IsDirected),
    term_vert::Vector{<:Integer},
    distmx::AbstractMatrix{U} = weights(g)
    ) where {U<:Real, T, AG<:AbstractGraph{T}}

    nvg = nv(g)
    term_to_actual = T.(term_vert)
    unique!(term_to_actual)

    # Compute the graph formed by inducing the metric closure graph of g on term_vert
    nvg_mc = length(term_to_actual)
    distmx_mc = Matrix{U}(undef, nvg_mc, nvg_mc)
    parents = Matrix{T}(undef, nvg, nvg_mc)

    for (i, v) in enumerate(term_to_actual)
        d_s = dijkstra_shortest_paths(g, v, distmx)
        @inbounds parents[:, i] = d_s.parents
        @inbounds distmx_mc[:, i] = @view d_s.dists[term_to_actual]
    end

    # Compute MST of Metric Closure graph
    mst_mc = kruskal_mst(complete_graph(nvg_mc), distmx_mc)
    expanded_mst = Vector{Edge{T}}()
    sizehint!(expanded_mst, nvg)

    # Expand each edge in mst_mc into the path it represents
    for e in mst_mc
        i = src(e)
        s = term_to_actual[i]
        t = term_to_actual[dst(e)]
        while s != t
            t_next = parents[t, i] 
            push!(expanded_mst, Edge(min(t_next, t), max(t_next, t))) 
            t = t_next
        end
    end

    # Compute the MST of the expanded graph
    mst_mst_mc = kruskal_mst(SimpleGraph(expanded_mst), distmx)    
        
    # Remove non-terminal leaves
    return filter_non_term_leaves!(SimpleGraph(mst_mst_mc), term_to_actual)
end
