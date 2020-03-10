export DegreeVertexCover

struct DegreeVertexCover end

"""
    vertex_cover(g, DegreeVertexCover())

Obtain a vertex cover using a greedy heuristic.

### Implementation Notes
An edge is said to be covered if it has at least one end-point in the vertex cover.
Initialise the vertex cover to an empty set and iteratively choose the vertex with the most uncovered
edges.

### Performance
Runtime: O((|V|+|E|)*log(|V|))
Memory: O(|V|)

# Examples
```jldoctest
julia> using LightGraphs

julia> vertex_cover(path_graph(3), DegreeVertexCover())
1-element Array{Int64,1}:
 2

julia> vertex_cover(cycle_graph(3), DegreeVertexCover())
2-element Array{Int64,1}:
 1
 3
```
"""
function vertex_cover(g::AbstractGraph{T}, alg::DegreeVertexCover) where {T<:Integer}

    nvg = nv(g)
    in_cover = falses(nvg)
    length_cover = 0
    degree_queue = PriorityQueue(Base.Order.Reverse, enumerate(degree(g)))

    while !isempty(degree_queue) && peek(degree_queue)[2] > 0
        v = dequeue!(degree_queue)
        in_cover[v] = true
        length_cover += 1

        @inbounds @simd for u in neighbors(g, v)
            if !in_cover[u]
                degree_queue[u] -= 1
            end
        end
    end
    return LightGraphs.findall!(in_cover, Vector{T}(undef, length_cover))
end
