"""
    bridges(g)

Compute the [bridges](https://en.m.wikipedia.org/wiki/Bridge_(graph_theory))
of a connected graph `g` and return an array containing all bridges, i.e edges
whose deletion increases the number of connected components of the graph.
# Examples
```jldoctest
julia> using LightGraphs

julia> bridges(StarGraph(5))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 1 => 4
 Edge 1 => 5

julia> bridges(PathGraph(5))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 4 => 5
 Edge 3 => 4
 Edge 2 => 3
 Edge 1 => 2
```
"""
function bridges end
@traitfn function bridges(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}}
    s = Vector{Tuple{T, T, T}}()
    low = zeros(T, nv(g))
    pre = zeros(T, nv(g))
    bridges = Edge{T}[]
    
    @inbounds for u in vertices(g)
        pre[u] != 0 && continue
        v = u
        wi::T = zero(T)
        w::T = zero(T)
        cnt::T = one(T)
        first_time = true

        while !isempty(s) || first_time
            first_time = false
            if  wi < 1
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
                if low[w] > pre[v]
                    edge = v < w ? Edge(v, w) : Edge(w, v)
                    push!(bridges, edge)
                end
                wi += 1
            end
            while wi <= length(v_neighbors)
                w = v_neighbors[wi]
                if pre[w] == 0
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
        
    end
    
    return bridges
end