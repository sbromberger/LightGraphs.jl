function common_neighbors(g::AbstractSimpleGraph, u::Integer, v::Integer)
    common = Vector{eltype(g)}()
    i, j = 1, 1
    u_len, v_len = length(g.fadjlist[u]), length(g.fadjlist[v])

    if u_len == 0 || v_len == 0
        return common
    end

    if (g.fadjlist[u][end] < g.fadjlist[v][1]) || (g.fadjlist[u][1] > g.fadjlist[v][end])
        return common
    end

    @inbounds while i <= u_len && j <= v_len
        if g.fadjlist[u][i] < g.fadjlist[v][j]
            i += 1
        elseif g.fadjlist[u][i] > g.fadjlist[v][j]
            j += 1
        else
            push!(common, g.fadjlist[u][i])
            i += 1
            j += 1
        end
    end

    return common
end

function intersect(g::T, h::T) where T <: AbstractSimpleGraph
   U = eltype(g)
   gnv = nv(g)
   hnv = nv(h)

   r = T(min(gnv, hnv))

   for u in vertices(r)
       (length(g.fadjlist[u]) == 0 || length(h.fadjlist[u]) == 0) && continue

       ((g.fadjlist[u][end] < h.fadjlist[u][1]) || (g.fadjlist[u][1] > h.fadjlist[u][end])) && continue

       i, j = 1, 1
       @inbounds while i <= length(g.fadjlist[u]) && j <= length(h.fadjlist[u])
            if g.fadjlist[u][i] < h.fadjlist[u][j]
                i += 1
            elseif g.fadjlist[u][i] > h.fadjlist[u][j]
                j += 1
            else
                add_edge!(r, u, g.fadjlist[u][i])
                i += 1
                j += 1
            end
       end
   end

   return r
end
