#A pseudo-peripheral node v has the property that for any node u, if v is as far away from u as possible, then u is as far away from v as possible.
function pseudo_peripheral_node(g, src)
    T = eltype(g)
    u = src
    lp = 0
    while true
        l = -1
        for i in gdistances(g, u)
            if i < typemax(T)
                l = max(i, l)
            end
        end
        l <= lp && break
        lp = l
        for v in outneighbors(g, u)
            if degree(g, v) < degree(g, u)
               u = v
            end
        end
    end
    return u
end

function connected_rcm!(vertex_permutation, visited, src,  g)
    T = eltype(g)
    start = pseudo_peripheral_node(g, src)
    q = Vector{T}()
    u_nbrs = Vector{T}()
    push!(q, start)
    @inbounds while !isempty(q)
        u = popfirst!(q)
        visited[u] = true
        push!(vertex_permutation, u)
        empty!(u_nbrs)
        for v in outneighbors(g, u)
            if !visited[v]
                push!(u_nbrs, v)
                visited[v] = true
            end
        end
        sort!(u_nbrs, by = v -> degree(g, v))
        for v in u_nbrs push!(q, v) end
    end
end

"""
    rcm_vertex_permutation(g)

Return the vertices in the new ordering. 
The reverse Cuthill-Mckee ordering algorithm reduces the bandwidth of a graph by reordering the indices assigned to each vertex.
"""
function rcm_vertex_permutation(g::SimpleGraph{T}) where T
    vertex_permutation = Vector{T}()
    visited = falses(nv(g))
    for i in vertices(g)
        if !visited[i]
            connected_rcm!(vertex_permutation, visited, i, g)
        end
    end
    return reverse!(vertex_permutation)
end
