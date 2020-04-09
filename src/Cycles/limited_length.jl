"""
    struct LimitedLength <: SimpleCycleAlgorithm

A [`SimpleCycleAlgorithm`](@ref) that specifies the use of a limited
length iterative algorithm. Both directed and undirected graphs
are supported.

### Required Parameters
`n::Int`: maximum length of cycles to be computed.

### Optional Parameters
`ceiling::Int`: maximum number of cycles to be computed (default 1e6).

### Performance
The number of cycles grows very fast with the number of vertices and
the allowed length of the cycles. This function is intended for
finding short cycles. If you want to find cycles of any length in a
directed graph, the [`Johnson`](@ref) algorithm may be more efficient.
"""
struct LimitedLength <: SimpleCycleAlgorithm
    n::Int
    ceiling::Int
end

LimitedLength(n::Integer; ceiling=Int(1e6)) = LimitedLength(n, ceiling)

function simple_cycles(graph::AbstractGraph{T}, alg::LimitedLength) where {T}
    cycles = Vector{Vector{T}}()
    alg.n < 1 && return cycles
    cycle = Vector{T}(undef, alg.n)
    @inbounds for v in vertices(graph)
        cycle[1] = v
        limited_length_simple_cycles!(graph, alg.n, alg.ceiling, cycles, cycle, 1)
        length(cycles) >= alg.ceiling && break
    end
    return cycles
end

function limited_length_simple_cycles!(graph, n, ceiling, cycles, cycle, i)
    length(cycles) >= ceiling && return
    for v in outneighbors(graph, cycle[i])
        if v == cycle[1]
            push!(cycles, cycle[1:i])
        elseif (i < n
                && v > cycle[1]
                && !repeated_vertex(v, cycle, 2, i))
            cycle[i + 1] = v
            limited_length_simple_cycles!(graph, n, ceiling, cycles, cycle, i + 1)
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
