"""
    bipartite_map(g) -> Vector{UInt8}

For a bipartite graph `g`, return a vector `c` of size ``|V|`` containing
the assignment of each vertex to one of the two sets (``c_i == 1`` or c_i == 2``).
If `g` is not bipartite, return an empty vector.

### Implementation Notes
Note that an empty vector does not necessarily indicate non-bipartiteness.
An empty graph will return an empty vector but is bipartite.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph();

julia> bipartite_map(g)
0-element Array{UInt8,1}

julia> add_vertices!(g, 3);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 2, 3);

julia> bipartite_map(g)
3-element Array{UInt8,1}:
 0x01
 0x02
 0x01
```
"""
function bipartite_map(g::AbstractGraph{T}) where T
    nvg = nv(g)
    if !is_directed(g)
        ccs = filter(x -> length(x) >= 2, connected_components(g))
    else
        ccs = filter(x -> length(x) >= 2, weakly_connected_components(g))
    end
    seen = zeros(Bool, nvg)
    colors = zeros(Bool, nvg)
    for cc in ccs
        Q = Vector{T}()
        s = cc[1]
        push!(Q, s)
        bipartitemap = zeros(UInt8, nvg)
        while !isempty(Q)
            u = popfirst!(Q)
            for v in outneighbors(g, u)
                if !seen[v]
                    colors[v] = !colors[u]
                    push!(Q, v)
                    seen[v] = true
                elseif colors[v] == colors[u]
                    return Vector{UInt8}()
                end
            end
        end
    end
    return UInt8.(colors).+(one(UInt8))
end

"""
    is_bipartite(g)

Return `true` if graph `g` is [bipartite](https://en.wikipedia.org/wiki/Bipartite_graph).

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(3);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 2, 3);

julia> is_bipartite(g)
true

julia> add_edge!(g, 1, 3);

julia> is_bipartite(g)
false
```
"""
is_bipartite(g::AbstractGraph) = length(bipartite_map(g)) == nv(g)
