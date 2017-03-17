abstract AbstractPathState
# modified from http://stackoverflow.com/questions/25678112/insert-item-into-a-sorted-list-with-julia-with-and-without-duplicates
# returns true if insert succeeded, false if it was a duplicate
_insert_and_dedup!{T<:Integer}(v::Vector{T}, x::T) = isempty(splice!(v, searchsorted(v,x), x))

"""Returns true if the edge is ordered (source vertex <= dest vertex)"""
is_ordered(e::AbstractEdge) = src(e) <= dst(e)

"""
Add `n` new vertices to the graph `g`.
Returns true if all vertices
were added successfully, false otherwise.
"""
add_vertices!(g::AbstractGraph, n::Integer) = all([add_vertex!(g) for i=1:n])

"""Return the number of edges which end at vertex `v`."""
indegree(g::AbstractGraph, v::Integer) = length(in_neighbors(g, v))
indegree{T<:Integer}(g::AbstractGraph, v::AbstractArray{T,1} = vertices(g)) = [indegree(g,x) for x in v]

"""Return the number of edges which start at vertex `v`."""
outdegree(g::AbstractGraph, v::Integer) = length(out_neighbors(g, v))
outdegree{T<:Integer}(g::AbstractGraph, v::AbstractArray{T,1} = vertices(g)) = [outdegree(g,x) for x in v]

"""
Return the number of edges from the vertex `v`.
For directed graphs, this value equals the incoming plus outgoing edges.
For undirected graphs, it equals the connected edges.
"""
degree(G::AbstractGraph, x...) = _NI("degree")
@traitfn degree{G<:AbstractGraph; IsDirected{G}}(g::G, v::Integer) = indegree(g, v) + outdegree(g, v)
@traitfn degree{G<:AbstractGraph; !IsDirected{G}}(g::G, v::Integer) = indegree(g, v)

degree{T<:Integer}(g::AbstractGraph, v::AbstractArray{T,1} = vertices(g)) = [degree(g, x) for x in v]

"Return the maximum `outdegree` of vertices in `g`."
Δout(g) = noallocextreme(outdegree,(>), typemin(Int), g)
"Return the minimum `outdegree` of vertices in `g`."
δout(g) = noallocextreme(outdegree,(<), typemax(Int), g)
"Return the maximum `indegree` of vertices in `g`."
Δin(g)  = noallocextreme(indegree,(>), typemin(Int), g)
"Return the minimum `indegree` of vertices in `g`."
δin(g)  = noallocextreme(indegree,(<), typemax(Int), g)
"Return the maximum `degree` of vertices in `g`."
Δ(g)    = noallocextreme(degree,(>), typemin(Int), g)
"Return the minimum `degree` of vertices in `g`."
δ(g)    = noallocextreme(degree,(<), typemax(Int), g)

"Computes the extreme value of `[f(g,i) for i=i:nv(g)]` without gathering them all"
function noallocextreme(f, comparison, initial, g)
    value = initial
    for i in vertices(g)
        funci = f(g, i)
        if comparison(funci, value)
            value = funci
        end
    end
    return value
end

"""
    degree_histogram(g)

Returns a `StatsBase.Histogram` of the degrees of vertices in `g`.
"""
degree_histogram(g::AbstractGraph) = fit(Histogram, degree(g))

"""
Return a list of all neighbors reachable from vertex `v` in `g`.
For DiGraphs, the default is equivalent to `out_neighbors(g, v)`;
use `all_neighbors` to list inbound and outbound neighbors.
NOTE: returns a reference, not a copy. Do not modify result.
"""
neighbors(g::AbstractGraph, v::Integer) = out_neighbors(g, v)

"""
Return a list of all inbound and outbound neighbors of `v` in `g`.
For undirected graphs, this is equivalent to `out_neighbors` and
`in_neighbors`.
"""
all_neighbors(x...) = _NI("all_neighbors")
@traitfn all_neighbors{G<:AbstractGraph; IsDirected{G}}(g::G, v::Integer) =
  union(out_neighbors(g, v), in_neighbors(g, v))
@traitfn all_neighbors{G<:AbstractGraph; !IsDirected{G}}(g::G, v::Integer) =
  neighbors(g, v)


"Returns the neighbors common to vertices `u` and `v` in `g`."
common_neighbors(g::AbstractGraph, u::Integer, v::Integer) =
  intersect(neighbors(g, u), neighbors(g, v))

"Returns true if `g` has any self loops."
has_self_loops(g::AbstractGraph) = nv(g) == 0? false : any(v->has_edge(g, v, v), vertices(g))

"Returns the number of self loops in `g`."
num_self_loops(g::AbstractGraph) = nv(g) == 0 ? 0 : sum(v->has_edge(g, v, v), vertices(g))

"""
Return the density of `g`.
Density is defined as the ratio of the number of actual edges to the
number of possible edges ( |v| |v-1| for directed graphs and
(|v| |v-1|) / 2 for undirected graphs).
"""
density(G::AbstractGraph) = _NI("density")
@traitfn density{G<:AbstractGraph; IsDirected{G}}(g::G) =
  ne(g) / (nv(g) * (nv(g)-1))
@traitfn density{G<:AbstractGraph; !IsDirected{G}}(g::G) =
  (2*ne(g)) / (nv(g) * (nv(g)-1))
