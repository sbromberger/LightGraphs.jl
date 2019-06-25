
"""
    IsMutable

Type characterizing the mutability/immutability of a graph type.

A mutable graph type `G` is expected to implement the mutability functions:
- `add_vertex!(g::G) -> Bool`
- `rem_vertex!(g::G, v) -> Bool`
- `add_edge!(g::G) -> Bool`
- `rem_edge!(g::G, i, j) -> Bool`
- `add_vertices!(g::G, n::Integer) -> Integer` (optional)
- `rem_vertices!(g::G, vs; keep_order::Boolean=false) -> vmap` (optional)
"""
abstract type IsMutable end

"""
    MutableGraph

Returned from `IsMutable(::Type{G})` when `G` is a type of mutable graph (supporting the mutable interface).
"""
struct MutableGraph end

"""
    ImmutableGraph

Returned from `IsMutable(::Type{G})` when `G` is a type of immutable graph.
"""
struct ImmutableGraph end

"""
    IsMutable(::Type{<:AbstractGraph})

Trait returning a value of `GraphMutability`, indicates whether a
graph type is mutable or not. Mutable graph types must implement the mutability
interface.
"""
IsMutable(::Type{<:AbstractGraph}) = ImmutableGraph()
IsMutable(::Type{<:AbstractSimpleGraph}) = MutableGraph()
IsMutable(::G) where {G <: AbstractGraph} = IsMutable(G)

LightGraphs.add_vertex!(g::G) where {G <: AbstractGraph} = add_vertex!(IsMutable(G), g)

function LightGraphs.add_vertex!(::MutableGraph, g::G) where {G <: AbstractGraph}
    throw(InterfaceException(G, "add_vertex!"))
end

function LightGraphs.add_vertex!(::ImmutableGraph, g::G) where {G <: AbstractGraph}
    throw(ImmutabilityException{G}())
end

LightGraphs.rem_vertex!(g::G, v) where {G <: AbstractGraph} = rem_vertex!(IsMutable(G), g, v)

function LightGraphs.rem_vertex!(::MutableGraph, g::G, v) where {G <: AbstractGraph}
    throw(InterfaceException(G, "rem_vertex!"))
end

function LightGraphs.rem_vertex!(::ImmutableGraph, g::G, v) where {G <: AbstractGraph}
    throw(ImmutabilityException{G}())
end

LightGraphs.add_edge!(g::G, args...) where {G <: AbstractGraph} = add_edge!(IsMutable(G), g, args...)

function LightGraphs.add_edge!(::MutableGraph, g::G, args...) where {G <: AbstractGraph}
    throw(InterfaceException(G, "add_edge!"))
end

function LightGraphs.add_edge!(::ImmutableGraph, g::G, args...) where {G <: AbstractGraph}
    throw(ImmutabilityException{G}())
end

LightGraphs.rem_edge!(g::G, i, j) where {G <: AbstractGraph} = add_edge!(IsMutable(G), g, i, j)

function LightGraphs.rem_edge!(::MutableGraph, g::G, i, j) where {G <: AbstractGraph}
    throw(InterfaceException(G, "rem_edge!"))
end

function LightGraphs.rem_edge!(::ImmutableGraph, g::G, i, j) where {G <: AbstractGraph}
    throw(ImmutabilityException{G}())
end

"""
    InterfaceException{G}

Thrown by default in case of a lack of implementation of a required function of the
LightGraphs interface for the type `G`.
"""
struct InterfaceException{G<:AbstractGraph} <: Exception
    f::String
end

InterfaceException(::Type{G}, func::F) where {G <: AbstractGraph, F} = InterfaceException{G}(string(func))

function Base.showerror(io::IO, iex::InterfaceException{G}) where {G}
    print(io, "Function $(iex.f) not implemented for $G")
end

struct ImmutabilityException{G<:AbstractGraph} <: Exception end

function Base.showerror(io::IO, ::ImmutabilityException{G}) where {G}
    print(io, "Graph type $G is immutable and does not support mutating operations")
end
