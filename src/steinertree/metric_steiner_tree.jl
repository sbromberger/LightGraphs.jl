"""
	metric_steiner_tree(g, distmx, term_vert)

`g` is a complete undirected graph.
Its positive edge weights represented by `distmx` and obeys the triangular inequality.
`term_vert` represent the terminal vertices of the steiner tree. 
Find a tree spanning `g` of minimum weight that connects all the terminal vertices.

Let t = `|term_vert|`

### Performance
Runtime: O(t^2 * log(t))
Approximation Factor: 2-2/t

### Implementation Notes
Perform [Approximate Metric Steiner Tree](lucatrevisan.wordpress.com/2011/01/13/cs261-lecture-2-steiner-tree-approximation/).
"""
function metric_steiner_tree end

@traitfn function metric_steiner_tree(
    g::AG::(!IsDirected),
    term_vert::Vector{<:Integer},
    distmx::AbstractMatrix{U} = weights(g)
    ) where {U<:Real, T, AG<:AbstractGraph{T}}


    term_to_actual = T.(unique(term_vert))
    nvg_t = length(term_to_actual)
    distmx_t = distmx[term_to_actual, term_to_actual]

    mst_t = kruskal_mst(CompleteGraph(nvg_t), distmx_t)

    for (i, e) in enumerate(mst_t)
        @inbounds mst_t[i] = Edge(term_to_actual[e.src], term_to_actual[e.dst])
    end
    return mst_t
end
