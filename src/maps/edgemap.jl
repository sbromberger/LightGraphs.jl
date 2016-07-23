type EdgeMap{T, G<:SimpleGraph, D}
    g::G
    data::D

    function EdgeMap(g::G, data::D)
        if D <: AbstractMatrix
            @assert eltype(data) == T
        elseif D <: Associative
            @assert valtype(data) == T
        end
        new(g, data)
    end
end

###### Constructors ###################
EdgeMap{G<:SimpleGraph,D<:Associative}(g::G, d::D) =
    EdgeMap{valtype(d),G,D}(g, d)
EdgeMap{D<:Associative}(d::D) =
    EdgeMap{valtype(d),Graph,D}(Graph(), d)

EdgeMap{G<:SimpleGraph, D<:AbstractMatrix}(g::G, d::D) =
    EdgeMap{eltype(d),G,D}(g, d)
EdgeMap{D<:AbstractMatrix}(d::D) =
    EdgeMap{eltype(d),Graph,D}(Graph(), d)


EdgeMap{T,G<:SimpleGraph}(::Type{T}, g::G) = EdgeMap(g, Dict{Edge,T}())
EdgeMap{T}(::Type{T}) = EdgeMap(Graph(), Dict{Edge,T}())

ConstEdgeMap{T,G<:SimpleGraph}(g::G, x::T) = EdgeMap{T, G, T}(g, x)
ConstEdgeMap{T}(x::T) = EdgeMap{T, Graph, T}(Graph(), x)

###### I/O ###################
show(io::IO, em::EdgeMap) = print(io, "EdgeMap($(em.data))")

###### Associative interface ###################
length(em::EdgeMap) = length(em.data)
eltype{T,G,D}(em::EdgeMap{T,G,D}) = Pair{Edge, T}
valtype{T,G,D}(em::EdgeMap{T,G,D}) = T
keytype{T,G,D}(em::EdgeMap{T,G,D}) = Edge
get{T,G,D}(em::EdgeMap{T,G,D}, e::Edge, x) = get(em.data, e, x)

### D <: Associative
getindex{T,G,D<:Associative}(em::EdgeMap{T,G,D}, e::Edge) = getindex(em.data, e)
setindex!{T,G,D<:Associative}(em::EdgeMap{T,G,D}, val, e::Edge) = setindex!(em.data, val, e)
haskey{T,G,D<:Associative}(em::EdgeMap{T,G,D}, e::Edge) = haskey(em.data, e)
get{T,G,D<:Associative}(em::EdgeMap{T,G,D}, e::Edge, x) = get(em.data, e, x)


### D <: AbstractMatrix
getindex{T,G,D<:AbstractMatrix}(em::EdgeMap{T,G,D}, e::Edge) = getindex(em.data, src(e), dst(e))
setindex!{T,G,D<:AbstractMatrix}(em::EdgeMap{T,G,D}, val, e::Edge) = setindex!(em.data, val, src(e), dst(e))
haskey{T,G,D<:AbstractMatrix}(em::EdgeMap{T,G,D}, e::Edge) = true
get{T,G,D<:AbstractMatrix}(em::EdgeMap{T,G,D}, e::Edge, x) = get(em.data, (src(e),dst(e)), x)


### ConstEdgeMap
setindex!{G,D<:Associative}(em::EdgeMap{D,G,D}, val, e::Edge) = error() # have to define this otherwise julia complains
setindex!{G,D<:AbstractMatrix}(em::EdgeMap{D,G,D}, val, e::Edge) = error() # have to define this otherwise julia complains
setindex!{T,G}(em::EdgeMap{T,G,T}, val, e::Edge) = val #; error("Cannot assign to ConstEdgeMap.")
get{G,D<:Associative}(em::EdgeMap{D,G,D}, e::Edge, x) = error()
get{G,D<:AbstractMatrix}(em::EdgeMap{D,G,D}, e::Edge, x) = error()
get{T,G}(em::EdgeMap{T,G,T}, e::Edge, x) = em.data

###### Matrix interface ###################
## TODO check u < v for Graphs

### D <: Associative
getindex{T,G,D<:Associative}(em::EdgeMap{T,G,D}, u::Int, v::Int) =
    getindex(em.data, Edge(u, v))
setindex!{T,G,D<:Associative}(em::EdgeMap{T,G,D}, val, u::Int, v::Int) =
    setindex!(em.data, val, Edge(u, v))

### D <: AbstractMatrix
getindex{T,G,D<:AbstractMatrix}(em::EdgeMap{T,G,D}, u::Int, v::Int) =
    getindex(em.data, u, v)
setindex!{T,G,D<:AbstractMatrix}(em::EdgeMap{T,G,D}, val, u::Int, v::Int) =
    setindex!(em.data, val, u, v)

### ConstEdgeMap
setindex!{G,D<:Associative}(em::EdgeMap{D,G,D}, val, u::Int, v::Int) = error() # have to define this otherwise julia complains
setindex!{G,D<:AbstractMatrix}(em::EdgeMap{D,G,D}, val, u::Int, v::Int) = error() # have to define this otherwise julia complains
setindex!{T,G}(em::EdgeMap{T,G,T}, val, u::Int, v::Int) = val #error("Cannot assign to ConstEdgeMap.")
getindex{G,D<:Associative}(em::EdgeMap{D,G,D}, u::Int, v::Int) = error() # have to define this otherwise julia complains
getindex{G,D<:AbstractMatrix}(em::EdgeMap{D,G,D}, u::Int, v::Int) = error() # have to define this otherwise julia complains
getindex{T,G}(em::EdgeMap{T,G,T}, u::Int, v::Int) = em.data

####### Iterable interface ######################

## D <: Associative
start{T,G,D<:Associative}(em::EdgeMap{T,G,D}) = start(em.data)
next{T,G,D<:Associative}(em::EdgeMap{T,G,D}, state)  = next(em.data, state)
done{T,G,D<:Associative}(em::EdgeMap{T,G,D}, state) = done(em.data, state)

# ### D <: AbstractMatrix
# start{T,G,D<:AbstractMatrix}(em::EdgeMap{T,G,D}) = start(em.data)
# function next{T,D<:AbstractMatrix}(em::EdgeMap{T,D}, state)
#     val, state2 = next(em.data, state)
#     sub = ind2sub(em.data, state)
#     return (Edge(sub[1], sub[2]), val), state2
# end
# done{T,D<:AbstractMatrix}(em::EdgeMap{T,D}, state) = done(em.data, state)
