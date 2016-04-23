type EdgeMap{T, D, G <: SimpleGraph}
    g::G
    data::D
end


typealias DefaultEdgeMap{T, G} EdgeMap{T, Dict{Edge,T}, G}
# typealias EdgeMap{T, G} EdgeMap{T, Dict{Edge, T}, G}

EdgeMap{T, G<:SimpleGraph}(::Type{T}, g::G) =
    DefaultEdgeMap{T, G}(g, Dict{Edge, T}())

show(io::IO, em::EdgeMap) = print(io, "EdgeMap($(em.data) on $(em.g))")

typealias ConstEdgeMap{T, G} EdgeMap{T, T, G}

ConstEdgeMap{G,T}(g::SimpleGraph, x::T) = EdgeMap{T, T, G}(g, x)

# Associative interface
getindex(em::EdgeMap, e::Edge) = getindex(em.data, e)
setindex!(em::EdgeMap, v, e::Edge) = setindex!(em.data, v, e)
eltype(::Type{EdgeMap}) = eltype(typeof(em.data))
length(em::EdgeMap) = length(em.data)

getindex(em::ConstEdgeMap, e::Edge) = em.data
setindex!(em::ConstEdgeMap, v, e::Edge) = error("Cannot assign to ConstEdgeMap.")

# Iterable interface
start(em::EdgeMap) = start(em.data)
next(em::EdgeMap, state)  = start(em.data)
done(em::EdgeMap, state) = done(em.data)
