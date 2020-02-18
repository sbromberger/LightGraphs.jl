"""
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`. Return `false` if removal fails
(e.g., if vertex is not in the graph); `true` otherwise.

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

function rem_vertices! end

function rem_edge! end

function add_vertex! end

function add_edge! end
