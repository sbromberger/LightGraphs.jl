abstract type AbstractPathState end
# modified from http://stackoverflow.com/questions/25678112/insert-item-into-a-sorted-list-with-julia-with-and-without-duplicates
# returns true if insert succeeded, false if it was a duplicate
_insert_and_dedup!{T<:Integer}(v::Vector{T}, x::T) = isempty(splice!(v, searchsorted(v,x), x))

"""
    is_ordered(e)
Return true if the source vertex of edge `e` is less than or equal to
the destination vertex.
"""
is_ordered(e::AbstractEdge) = src(e) <= dst(e)

"""
    add_vertices!(g, n)
Add `n` new vertices to the graph `g`.
Return `true` if all vertices were added successfully, `false` otherwise.
"""
add_vertices!(g::AbstractGraph, n::Integer) = all([add_vertex!(g) for i=1:n])

"""
    indegree(g[, v])

Return a vector corresponding to the number of edges which end at each vertex in
graph `g`. If `v` is specified, only return degrees for vertices in `v`.
"""
indegree(g::AbstractGraph, v::Integer) = length(in_neighbors(g, v))
indegree(g::AbstractGraph, v::AbstractVector = vertices(g)) = [indegree(g,x) for x in v]

"""
    outdegree(g[, v])

Return a vector corresponding to the number of edges which start at each vertex in
graph `g`. If `v` is specified, only return degrees for vertices in `v`.
"""
outdegree(g::AbstractGraph, v::Integer) = length(out_neighbors(g, v))
outdegree(g::AbstractGraph, v::AbstractVector = vertices(g)) = [outdegree(g,x) for x in v]

"""
    degree(g[, v])
Return a vector corresponding to the number of edges which start or end at each
vertex in graph `g`. If `v` is specified, only return degrees for vertices in `v`.
For directed graphs, this value equals the incoming plus outgoing edges.
For undirected graphs, it equals the connected edges.
"""
function degree end
@traitfn degree(g::::IsDirected, v::Integer) = indegree(g, v) + outdegree(g, v)
@traitfn degree(g::::(!IsDirected), v::Integer) = indegree(g, v)

degree(g::AbstractGraph, v::AbstractVector = vertices(g)) = [degree(g, x) for x in v]

"""
    Δout(g)

Return the maximum [`outdegree`](@ref) of vertices in `g`.
"""
Δout(g) = noallocextreme(outdegree,(>), typemin(Int), g)
"""
    δout(g)

Return the minimum [`outdegree`](@ref) of vertices in `g`.
"""
δout(g) = noallocextreme(outdegree,(<), typemax(Int), g)

"""
    Δin(g)

Return the maximum [`indegree`](@ref) of vertices in `g`.
"""
Δin(g) = noallocextreme(indegree,(>), typemin(Int), g)

"""
    δin(g)

Return the minimum [`indegree`](ref) of vertices in `g`.
"""
δin(g) = noallocextreme(indegree,(<), typemax(Int), g)

"""
    Δ(g)

Return the maximum [`degree`](@ref) of vertices in `g`.
"""
Δ(g) = noallocextreme(degree,(>), typemin(Int), g)

"""
    δ(g)
Return the minimum [`degree`](@ref) of vertices in `g`.
"""
δ(g) = noallocextreme(degree,(<), typemax(Int), g)


"""
    noallocextreme(f, comparison, initial, g)
Compute the extreme value of `[f(g,i) for i=i:nv(g)]` without gathering them all
"""
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
    degree_histogram(g, degfn=degree)

Return a Dict with values representing the number of vertices that have degree
represented by the key.

Degree function (for example, `indegree` or `outdegree`) may be specified by
overriding `degfn`.
"""
function degree_histogram(g::AbstractGraph, degfn=degree)
    hist = Dict{eltype(g), Int}()
    for v in vertices(g)        # minimize allocations by
        for d in degfn(g, v)    # iterating over vertices
            hist[d] = get(hist, d, 0) + 1
        end
    end
    return hist
end


"""
    neighbors(g, v)

Return a list of all neighbors reachable from vertex `v` in `g`.
For directed graphs, the default is equivalent to [`out_neighbors`](@ref);
use [`all_neighbors`](@ref) to list inbound and outbound neighbors.

### Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
neighbors(g::AbstractGraph, v::Integer) = out_neighbors(g, v)

"""
    all_neighbors(g, v)
Return a list of all inbound and outbound neighbors of `v` in `g`.
For undirected graphs, this is equivalent to both [`out_neighbors`](@ref)
and [`in_neighbors`](@ref).

### Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
function all_neighbors end
@traitfn all_neighbors(g::::IsDirected, v::Integer) =
    union(out_neighbors(g, v), in_neighbors(g, v))
@traitfn all_neighbors(g::::(!IsDirected), v::Integer) =
    neighbors(g, v)


"""
    common_neighbors(g, u, v)

Return the neighbors common to vertices `u` and `v` in `g`.

### Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
common_neighbors(g::AbstractGraph, u::Integer, v::Integer) =
    intersect(neighbors(g, u), neighbors(g, v))

"""
    has_self_loops(g)

Return true if `g` has any self loops.
"""
has_self_loops(g::AbstractGraph) = nv(g) == 0? false : any(v->has_edge(g, v, v), vertices(g))

"""
    num_self_loops(g)

Return the number of self loops in `g`.
"""
num_self_loops(g::AbstractGraph) = nv(g) == 0 ? 0 : sum(v->has_edge(g, v, v), vertices(g))

@doc_str """
    density(g)
Return the density of `g`.
Density is defined as the ratio of the number of actual edges to the
number of possible edges (``|V|×(|V|-1)`` for directed graphs and
``\\frac{|V|×(|V|-1)}{2}`` for undirected graphs).
"""
function density end
@traitfn density(g::::IsDirected) =
ne(g) / (nv(g) * (nv(g)-1))
@traitfn density(g::::(!IsDirected)) =
(2*ne(g)) / (nv(g) * (nv(g)-1))


"""
    squash(g)

Return a copy of a graph with the smallest practical type that
can accommodate all vertices.
"""
function squash(g::AbstractGraph)
    gtype = is_directed(g)? DiGraph : Graph
    validtypes = [UInt8, UInt16, UInt32, UInt64, Int]
    nvg = nv(g)
    for T in validtypes
        nvg < typemax(T) && return gtype{T}(g)
    end
end
