"""
    struct DFSQ <: WeakConnectivityAlgorithm

A struct representing a [`WeakConnectivityAlgorithm`](@ref)
based on an optimized depth-first search.
"""
struct DFSQ <: WeakConnectivityAlgorithm end


function connected_components!(label::AbstractVector, g::AbstractGraph{T}) where T
    nvg = nv(g)
    Q = Queue{T}()
    @inbounds for u in vertices(g)
        label[u] != zero(T) && continue
        label[u] = u
        enqueue!(Q, u)
        while !isempty(Q)
            src = dequeue!(Q)
            for vertex in all_neighbors(g, src)
                if label[vertex] == zero(T)
                    enqueue!(Q, vertex)
                    label[vertex] = u
                end
            end
        end
    end
    return label
end


function connected_components(g::AbstractGraph{T}, ::DFSQ) where {T}
    labels = zeros(T, nv(g))
    return components(connected_components!(labels, g))[1]
end
