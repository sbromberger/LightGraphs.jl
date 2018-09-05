"""
    simplecycles_limited_length(g, n, ceiling=10^6)

Compute and return at most `ceiling` cycles of length at most `n` of
the given graph. Both directed and undirected graphs are supported.

### Performance
The number of cycles grows very fast with the number of vertices and
the allowed length of the cycles. This function is intended for
finding short cycles. If you want to find cycles of any length in a
directed graph, `simplecycles` or `simplecycles_iter` may be more
efficient.
"""
function simplecycles_limited_length(graph::AbstractGraph, n::Integer,
                                     ceiling = 10^6)
    cycles = Vector{Int}[]
    n < 1 && return cycles
    cycle = Int[]
    for v = 1:nv(graph)
        push!(cycle, v)
        simplecycles_limited_length!(graph, n, ceiling, cycles, cycle)
        pop!(cycle)
        length(cycles) >= ceiling && break
    end
    return cycles
end

function simplecycles_limited_length!(graph, n, ceiling, cycles, cycle)
    length(cycles) >= ceiling && return
    for v in outneighbors(graph, cycle[end])
        if v == cycle[1]
            push!(cycles, copy(cycle))
        elseif (length(cycle) < n
                && v > cycle[1]
                && !repeated_vertex(v, cycle, 2, length(cycle)))
            push!(cycle, v)
            simplecycles_limited_length!(graph, n, ceiling, cycles, cycle)
            pop!(cycle)
        end
    end
end

# Note: Doing the same thing as `@views v in cycle[n1:n2]`, but until
# views are completely allocation free this can be expected to be
# faster.
function repeated_vertex(v, cycle, n1, n2)
    for k = n1:n2
        if cycle[k] == v
            return true
        end
    end
    return false
end
