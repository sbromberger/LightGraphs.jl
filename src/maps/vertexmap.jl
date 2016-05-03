type VertexMap{T, G<:SimpleGraph, D}
    g::G
    data::D

    function VertexMap(g::G, data::D)
        if D <: AbstractVector
            @assert eltype(data) == T
        elseif D <: Associative
            @assert valtype(data) == T
        end
        new(g, data)
    end
end

###### Constructors ###################
VertexMap{G<:SimpleGraph,D<:Associative}(g::G, d::D) =
    VertexMap{valtype(d),G,D}(g, d)
VertexMap{D<:Associative}(d::D) =
    VertexMap{valtype(d),Graph,D}(Graph(), d)

VertexMap{G<:SimpleGraph, D<:AbstractVector}(g::G, d::D) =
    VertexMap{eltype(d),G,D}(g, d)
VertexMap{D<:AbstractVector}(d::D) =
    VertexMap{eltype(d),Graph,D}(Graph(), d)


VertexMap{T,G<:SimpleGraph}(::Type{T}, g::G) = VertexMap(g, Dict{Edge,T}())
VertexMap{T}(::Type{T}) = VertexMap(Graph(), Dict{Int,T}())

ConstVertexMap{T,G<:SimpleGraph}(g::G, x::T) = VertexMap{T, G, T}(g, x)
ConstVertexMap{T}(x::T) = VertexMap{T, Graph, T}(Graph(), x)

###### I/O ###################
show(io::IO, vm::VertexMap) = print(io, "VertexMap($(vm.data))")

###### Associative interface ###################
length(vm::VertexMap) = length(vm.data)
eltype{T,G,D}(vm::VertexMap{T,G,D}) = Pair{Int, T}
valtype{T,G,D}(vm::VertexMap{T,G,D}) = T
keytype{T,G,D}(vm::VertexMap{T,G,D}) = Int
get{T,G,D}(vm::VertexMap{T,G,D}, v::Integer, x) = get(vm.data, v, x)

getindex{T,G,D}(vm::VertexMap{T,G,D}, v::Integer) = getindex(vm.data, v)
setindex!{T,G,D}(vm::VertexMap{T,G,D}, val, v::Integer) = setindex!(vm.data, val, v)

haskey{T,G,D<:Associative}(vm::VertexMap{T,G,D}, v::Integer) = haskey(vm.data, v)
haskey{T,G,D<:AbstractVector}(vm::VertexMap{T,G,D}, v::Integer) = true


### ConstVertexMap
setindex!{T,G}(vm::VertexMap{T,G,T}, val, v::Integer) = val #; error("Cannot assign to ConstVertexMap.")
get{T,G}(vm::VertexMap{T,G,T}, v::Integer, x) = vm.data

####### Iterable interface ######################

## D <: Associative
start{T,G,D<:Associative}(vm::VertexMap{T,G,D}) = start(vm.data)
next{T,G,D<:Associative}(vm::VertexMap{T,G,D}, state)  = next(vm.data, state)
done{T,G,D<:Associative}(vm::VertexMap{T,G,D}, state) = done(vm.data, state)

# ### D <: AbstractVector
# start{T,G,D<:AbstractVector}(vm::VertexMap{T,G,D}) = start(vm.data)
# function next{T,D<:AbstractVector}(vm::VertexMap{T,D}, state)
#     val, state2 = next(vm.data, state)
#     sub = ind2sub(vm.data, state)
#     return (Edge(sub[1], sub[2]), val), state2
# end
# done{T,D<:AbstractVector}(vm::VertexMap{T,D}, state) = done(vm.data, state)
