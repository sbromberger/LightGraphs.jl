function pseudo_peripheral_node(g::SimpleGraph, src)
    T = eltype(g)
    u::T = src
    lp = 0
    while true
        l = maximum(gdistances(g, u))
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

function connected_rcm(g::SimpleGraph, visited, cm, src)
    T = eltype(g)
    start::T = pseudo_peripheral_node(g, src)
    q = Vector{T}()
    push!(q, start)
    while !isempty(q)
        u::T = popfirst!(q)
        visited[u] = true
        push!(cm, u)
        u_nbrs = Vector{T}()
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

function reverse_cuthill_mckee(g::SimpleGraph)
    T = eltype(g)
    cm = Vector{T}()
    visited = falses(nv(g))
    for i in vertices(g)
        if !visited[i]
            connected_rcm(g, visited, cm, i)
        end
    end
    return reverse(cm)
end
