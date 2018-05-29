"""
	metric_steiner_tree(g, distmx, term_vert)

`g` is a complete undirected graph.
Its positive edge weights represented by `distmx` and obeys the triangular inequality.
`term_vert` represent the terminal vertices of the steiner tree. 
Finds a tree spanning `g` of minimum weight that connects all the terminal vertices.

### Notes
Triangular inequality: distmx[a, c] <= distmx[a, b] + distmx[b, c] for all vertices in `g`.

### Input Constraints
Assumes `g` has an edge for any 2 distinct vertices. 
distmx obeys the triangle inequality.

Let t = `|term_vert|`
### Approximation Factor
2-2/t

### Runtime
O(t^2 * log(t))

### Implementation Notes
Perform [Approximate Metric Steiner Tree](lucatrevisan.wordpress.com/2011/01/13/cs261-lecture-2-steiner-tree-approximation/).
"""
function metric_steiner_tree(
	g::AbstractGraph{T},
	term_vert::Vector{<:Integer},
	distmx::AbstractMatrix{U}=weights(g)
	) where T <: Integer where U <: Real 

	is_directed(g) && return Vector{Edge}()

	term_to_actual = unique(term_vert)
	nvg_t = size(term_to_actual)[1]
	distmx_t = Matrix{U}(undef, nvg_t, nvg_t)
	for (i, v) in enumerate(term_to_actual)
		for (j, u) in enumerate(term_to_actual)
			(i != j) && (distmx_t[j, i] = distmx[u, v])
		end
	end

	mst_t = kruskal_mst(CompleteGraph(nvg_t), distmx_t)

	for (i, e) in enumerate(mst_t)
		@inbounds mst_t[i] = Edge(term_to_actual[e.src], term_to_actual[e.dst])
	end
	return mst_t
end
