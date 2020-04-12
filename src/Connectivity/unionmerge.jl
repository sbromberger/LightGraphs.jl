struct UnionMerge <: WeakConnectivityAlgorithm end

function connected_components(g::AbstractGraph{T}, ::UnionMerge) where {T<:Integer}
    comps = IntDisjointSets{T}(nv(g))
    for e in edges(g)
        union!(comps, src(e), dst(e))
    end
    return components([find_root!(comps, x) for x in vertices(g)])[1]
end

