import Base: Pair, Tuple, show, ==
import LightGraphs: AbstractEdge, src, dst, reverse

abstract type AbstractSimpleEdge <: AbstractEdge end

struct SimpleEdge{T<:Integer} <: AbstractSimpleEdge
    src::T
    dst::T
end

SimpleEdge(t::Tuple) = SimpleEdge(t[1], t[2])
SimpleEdge(p::Pair) = SimpleEdge(p.first, p.second)
SimpleEdge{T}(p::Pair) where T<:Integer = SimpleEdge(T(p.first), T(p.second))
SimpleEdge{T}(t::Tuple) where T<:Integer = SimpleEdge(T(t[1]), T(t[2]))

eltype(e::T) where T<:AbstractSimpleEdge = eltype(src(e))

# Accessors
src(e::AbstractSimpleEdge) = e.src
dst(e::AbstractSimpleEdge) = e.dst

# I/O
show(io::IO, e::AbstractSimpleEdge) = print(io, "Edge $(e.src) => $(e.dst)")

# Conversions
Pair(e::AbstractSimpleEdge) = Pair(src(e), dst(e))
Tuple(e::AbstractSimpleEdge) = (src(e), dst(e))

(::Type{SimpleEdge{T}})(e::AbstractSimpleEdge) where T <: Integer = SimpleEdge{T}(T(e.src), T(e.dst))

# Convenience functions
reverse(e::T) where T<:AbstractSimpleEdge = T(dst(e), src(e))
==(e1::AbstractSimpleEdge, e2::AbstractSimpleEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2))
