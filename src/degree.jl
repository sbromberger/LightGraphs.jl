"""Return the number of edges which end at vertex `v`."""
outdegree(g::AbstractSparseGraph) = diff(g.fm.colptr)
outdegree(g::AbstractSparseGraph, v::Int) = g.fm.colptr[v+1]-g.fm.colptr[v]
outdegree(g::AbstractSparseGraph, v::AbstractVector{Int}) = [outdegree(g,x) for x in v]


"""Return the number of edges which start at vertex `v`."""
indegree(g::SparseDiGraph) = diff(g.bm.colptr)
indegree(g::SparseDiGraph, v::Int) = g.bm.colptr[v+1]-g.bm.colptr[v]
indegree(g::SparseDiGraph, v::AbstractVector{Int}) = [indegree(g,x) for x in v]
indegree(g::SparseGraph, x...) = outdegree(g,x...)


"""Return the number of edges (both ingoing and outgoing) from the vertex `v`."""
degree(g::Graph, x...) = outdegree(g,x...)
degree(g::DiGraph, x...) = indegree(g,x...) + outdegree(g,x...)

"Return the maxium `outdegree` of vertices in `g`."
Δout(g::AbstractSparseGraph)  = maximum(outdegree(g))
"Return the minimum `outdegree` of vertices in `g`."
δout(g::AbstractSparseGraph)  = minimum(outdegree(g))
"Return the maximum `indegree` of vertices in `g`."
Δin(g::AbstractSparseGraph)   = maximum(indegree(g))
"Return the minimum `indegree` of vertices in `g`."
δin(g::AbstractSparseGraph)   = minimum(indegree(g))
"Return the maximum `degree` of vertices in `g`."
Δ(g::AbstractSparseGraph)     = maximum(degree(g))
"Return the minimum `degree` of vertices in `g`."
δ(g::AbstractSparseGraph)     = minimum(degree(g))

"""Produces a histogram of degree values across all vertices for the graph `g`.
The number of histogram buckets is based on the number of vertices in `g`.
"""
degree_histogram(g::SimpleGraph) = (hist(degree(g), 0:nv(g)-1)[2])
