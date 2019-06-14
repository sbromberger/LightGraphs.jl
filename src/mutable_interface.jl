

"""
    add_vertex!(g)

Add a new vertex to the graph `g`. Return `true` if addition was successful.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(Int8(typemax(Int8) - 1))
{126, 0} undirected simple Int8 graph

julia> add_vertex!(g)
true

julia> add_vertex!(g)
false
```
"""
function add_vertex! end

"""
    add_edge!(g, e)

Add an edge `e` to graph `g`. Return `true` if edge was added successfully,
otherwise return `false`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2)
true

julia> add_edge!(g, 2, 3)
false
```
"""
function add_edge! end

"""
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`. Return `false` if removal fails
(e.g., if vertex is not in the graph); `true` otherwise.

### Performance
Time complexity is ``\\mathcal{O}(k^2)``, where ``k`` is the max of the degrees
of vertex ``v`` and vertex ``|V|``.

### Implementation Notes
This operation has to be performed carefully if one keeps external
data structures indexed by edges or vertices in the graph, since
internally the removal is performed swapping the vertices `v`  and ``|V|``,
and removing the last vertex ``|V|`` from the graph. After removal the
vertices in `g` will be indexed by ``1:|V|-1``.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(2);

julia> rem_vertex!(g, 2)
true

julia> rem_vertex!(g, 2)
false
```
"""
function rem_vertex! end

"""
    rem_edge!(g, e)

Remove an edge `e` from graph `g`. Return `true` if edge was removed successfully,
otherwise return `false`.

### Implementation Notes
If `rem_edge!` returns `false`, the graph may be in an indeterminate state, as
there are multiple points where the function can exit with `false`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2);

julia> rem_edge!(g, 1, 2)
true

julia> rem_edge!(g, 1, 2)
false
```
"""
function rem_edge! end

"""
    add_vertices!(g, n)

Add `n` new vertices to the graph `g`.
Return the number of vertices that were added successfully.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph()
{0, 0} undirected simple Int64 graph

julia> add_vertices!(g, 2)
2
```
"""
add_vertices!(g::AbstractGraph, n::Integer) = sum(add_vertex!(g) for i = 1:n)

"""
    rem_vertices!(g, vs, keep_order=false) -> vmap

Remove all vertices in `vs` from `g`.
Return a vector `vmap` that maps the vertices in the modified graph to the ones in
the unmodified graph.
If `keep_order` is `true`, the vertices in the modified graph appear in the same
order as they did in the unmodified graph. This might be slower.

### Implementation Notes
This function is not part of the official LightGraphs API and is subject to change/removal between major versions.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = CompleteGraph{5}
{5, 10} undirected simple Int64 graph

julia> vmap = rem_vertices!(g, [2, 4], keep_order=true);

julia> vmap
3-element Array{Int64,1}:
 1
 3
 5

julia> g
{3, 3} undirected simple Int64 graph
```
"""
function rem_vertices! end
