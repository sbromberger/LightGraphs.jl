type EdgeMap{T, D, G <: SimpleGraph}
    g::G
    data::D
end

getindex(em::EdgeMap, e::Edge) = setindex(em, data[e])
setindex!(t::EdgeMap, v, e::Edge) = setindex!(em.data, v, e)

# typealias EdgeMap{T, G} EdgeMap{T, Dict{Edge, T}, G}

EdgeMap{T, G<:SimpleGraph}(::Type{T}, g::G) =
        EdgeMap{T, Dict{Edge, T}, G}(g, Dict{Edge, T}())

show(io::IO, em::EdgeMap) = print(io, "EdgeMap($(em.data) on $(em.g))") 
