"""
	steiner_tree(g, distmx, term_vert)

`g` is a connected undirected graph.
Its positive edge weights represented by `distmx`.
`term_vert` represent the terminal vertices of the steiner tree. 
Finds a tree spanning `g` of minimum weeight that connects all the terminal vertices.

Let t = `|term_vert|`
### Approximation Factor
2-2/t

### Runtime
O(t*(t*log(t)+|E|*log(|V| ))

### Implementation Notes
Perform [Approximate Metric Steiner Tree](lucatrevisan.wordpress.com/2011/01/13/cs261-lecture-2-steiner-tree-approximation).
"""
function steiner_tree(
	g::AbstractGraph{T},
	distmx::AbstractMatrix{U},
	term_vert::Vector
	) where T <: Integer where U <: Real 

	nvg = nv(g)
	term_to_actual = unique(term_vert)
	nvg_t = size(term_to_actual)[1]

	parents = Matrix{T}(undef, nvg_t, nvg)
	distmx_t = Matrix{U}(undef, nvg_t, nvg_t)
	for (i, v) in enumerate(term_to_actual)
		d_s = dijkstra_shortest_paths(g, v, distmx)
		parents[i, :] = d_s.parents
		for (j, u) in enumerate(term_to_actual)
			distmx_t[i, j] = d_s.dists[u]
		end
	end

	mst_t = kruskal_mst(CompleteGraph(nvg_t), distmx_t)
	steiner_tree = Vector{Edge}()
	for e in mst_t
		i = e.src
		s = term_to_actual[i]
		t = term_to_actual[e.dst]
		while s != t #Retrieve the path represented by the edge s-t
			t_next = parents[i, t] 
			push!(steiner_tree, Edge(min(t_next, t), max(t_next, t)))
			t = t_next
		end
	end

	unique!(steiner_tree)
	return steiner_tree
end
