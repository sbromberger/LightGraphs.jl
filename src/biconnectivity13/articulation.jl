"""
    articulation(g)

Compute the [articulation points](https://en.wikipedia.org/wiki/Biconnected_component)
of a connected graph `g` and return an array containing all cut vertices.

# Examples
```jldoctest
julia> using LightGraphs

julia> articulation(star_graph(5))
1-element Array{Int64,1}:
 1

julia> articulation(path_graph(5))
3-element Array{Int64,1}:
 2
 3
 4
```
"""
function articulation end
@traitfn function articulation(g::AG::(!IsDirected)) where {T, AG <: AbstractGraph{T}}
    s = Vector{Tuple{T, T, T}}()
    is_articulation_pt = falses(nv(g))
    low = zeros(T, nv(g))
    pre = zeros(T, nv(g))

    @inbounds for u in vertices(g)
        pre[u] != 0 && continue
        v = u
        children = 0
        wi::T = zero(T)
        w::T = zero(T)
        cnt::T = one(T)
        first_time = true

        while !isempty(s) || first_time
            first_time = false
            if wi < 1
                pre[v] = cnt
                cnt += 1
                low[v] = pre[v]
                v_neighbors = outneighbors(g, v)
                wi = 1
            else
                wi, u, v = pop!(s)
                v_neighbors = outneighbors(g, v)
                w = v_neighbors[wi]
                low[v] = min(low[v], low[w])
                if low[w] >= pre[v] && u != v
                    is_articulation_pt[v] = true
                end
                wi += 1
            end
            while wi <= length(v_neighbors)
                w = v_neighbors[wi]
                if pre[w] == 0
                    if u == v
                        children += 1
                    end
                    push!(s, (wi, u, v))
                    wi = 0
                    u = v
                    v = w
                    break
                elseif w != u
                    low[v] = min(low[v], pre[w])
                end
                wi += 1
            end
            wi < 1 && continue
        end

        if children > 1
            is_articulation_pt[u] = true
        end
    end

    articulation_points = Vector{T}()

    for u in findall(is_articulation_pt)
        push!(articulation_points, T(u))
    end

    return articulation_points
end
