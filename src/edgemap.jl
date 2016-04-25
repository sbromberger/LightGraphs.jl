typealias DEM{T} Dict{Edge, T}
type EdgeMap{T, D}
    data::D

    EdgeMap() = EdgeMap{T, D}(D())

    function EdgeMap(data::D)
        if D <: AbstractMatrix
            @assert eltype(data) == T
        elseif D <: Associative
            @assert valtype(data) == T
        end
        new(data)
    end
end

###### Constructors ###################
EdgeMap{D<:Associative}(d::D) = EdgeMap{valtype(d), D}(d)
EdgeMap{D<:AbstractMatrix}(d::D) = EdgeMap{eltype(d), D}(d)
EdgeMap{T}(::Type{T}) = EdgeMap{T, DEM{T}}(DEM{T}())

ConstEdgeMap{T}(x::T) = EdgeMap{T,T}(x)

###### I/O ###################
show(io::IO, em::EdgeMap) = print(io, "EdgeMap($(em.data))")

###### Associative interface ###################
length(em::EdgeMap) = length(em.data)
eltype{T,D}(em::EdgeMap{T,D}) = Pair{Edge, T}
valtype{T,D}(em::EdgeMap{T,D}) = T
keytype{T,D}(em::EdgeMap{T,D}) = Edge

### D <: Associative
getindex{T, D<:Associative}(em::EdgeMap{T, D}, e::Edge) = getindex(em.data, e)
setindex!{T, D<:Associative}(em::EdgeMap{T, D}, val, e::Edge) = setindex!(em.data, val, e)

### D <: AbstractMatrix
getindex{T, D<:AbstractMatrix}(em::EdgeMap{T, D}, e::Edge) = getindex(em.data, src(e), dst(e))
setindex!{T, D<:AbstractMatrix}(em::EdgeMap{T, D}, val, e::Edge) = setindex!(em.data, val, src(e), dst(e))

### ConstEdgeMap
setindex!{D<:Associative}(em::EdgeMap{D, D}, val, e::Edge) = error() # have to define this otherwise julia complains
setindex!{T}(em::EdgeMap{T,T}, val, e::Edge) = error("Cannot assign to ConstEdgeMap.")

###### Matrix interface ###################
## TODO check u < v for Graphs

### D <: Associative
getindex{T, D<:Associative}(em::EdgeMap{T, D}, u::Int, v::Int) =
    getindex(em.data, Edge(u, v))
setindex!{T, D<:Associative}(em::EdgeMap{T, D}, val, u::Int, v::Int) =
    setindex!(em.data, val, Edge(u, v))

### D <: AbstractMatrix
getindex{T, D<:AbstractMatrix}(em::EdgeMap{T, D}, u::Int, v::Int) =
    getindex(em.data, u, v)
setindex!{T, D<:AbstractMatrix}(em::EdgeMap{T, D}, val, u::Int, v::Int) =
    setindex!(em.data, val, u, v)

### ConstEdgeMap
setindex!{D<:Associative}(em::EdgeMap{D, D}, val, u::Int, v::Int) = error() # have to define this otherwise julia complains
setindex!{T}(em::EdgeMap{T,T}, val, u::Int, v::Int) = error("Cannot assign to ConstEdgeMap.")

####### Iterable interface ######################
start(em::EdgeMap) = start(em.data)
next(em::EdgeMap, state)  = next(em.data, state)
done(em::EdgeMap, state) = done(em.data, state)
