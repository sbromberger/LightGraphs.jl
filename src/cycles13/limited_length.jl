"""
    simplecycles_limited_length(g, n, ceiling=10^6)

Compute and return at most `ceiling` cycles of length at most `n` of
the given graph. Both directed and undirected graphs are supported.

### Performance
The number of cycles grows very fast with the number of vertices and
the allowed length of the cycles. This function is intended for
finding short cycles. If you want to find cycles of any length in a
directed graph, [`simplecycles`](@ref) or [`simplecycles_iter`](@ref) may be more
efficient.
"""
function simplecycles_limited_length(
    graph::AbstractGraph{T},
    n::Int,
    ceiling = 10^6,
) where {T}
    cycles = Vector{Vector{T}}()
    n < 1 && return cycles
    cycle = Vector{T}(undef, n)
    @inbounds for v in vertices(graph)
        cycle[1] = v
        simplecycles_limited_length!(graph, n, ceiling, cycles, cycle, 1)
        length(cycles) >= ceiling && break
    end
    return cycles
end

function simplecycles_limited_length!(graph, n, ceiling, cycles, cycle, i)
    length(cycles) >= ceiling && return
    for v in outneighbors(graph, cycle[i])
        if v == cycle[1]
            push!(cycles, cycle[1:i])
        elseif (i < n && v > cycle[1] && !repeated_vertex(v, cycle, 2, i))
            cycle[i+1] = v
            simplecycles_limited_length!(graph, n, ceiling, cycles, cycle, i + 1)
        end
    end
end

# Note: Doing the same thing as `@views v in cycle[n1:n2]`, but until
# views are completely allocation free this can be expected to be
# faster.
function repeated_vertex(v, cycle, n1, n2)
    for k = n1:n2
        cycle[k] == v && return true
    end
    return false
end
