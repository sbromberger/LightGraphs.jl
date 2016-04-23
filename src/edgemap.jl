type EdgeMap{T, D, G <: SimpleGraph}
    g::G
    data::D
end

getindex(em::EdgeMap, e::Edge) = getindex(em.data, e)
setindex!(t::EdgeMap, v, e::Edge) = setindex!(em.data, v, e)

typealias DefaultEdgeMap{T, G} EdgeMap{T, Dict{Edge,T}, G}
# typealias EdgeMap{T, G} EdgeMap{T, Dict{Edge, T}, G}

EdgeMap{T, G<:SimpleGraph}(::Type{T}, g::G) =
    DefaultEdgeMap{T, G}(g, Dict{Edge, T}())

show(io::IO, em::EdgeMap) = print(io, "EdgeMap($(em.data) on $(em.g))")

typealias ConstEdgeMap{T, G} EdgeMap{T, T, G}

ConstEdgeMap{G,T}(g::SimpleGraph, x::T) = EdgeMap{T, T, G}(g, x)

getindex(em::ConstEdgeMap, e::Edge) = em.data
setindex!(t::ConstEdgeMap, v, e::Edge) = error("Cannot assign to ConstEdgeMap.")
