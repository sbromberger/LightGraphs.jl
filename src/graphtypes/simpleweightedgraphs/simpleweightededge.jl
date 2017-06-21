import Base: Pair, Tuple, show, ==
import LightGraphs: AbstractEdge, src, dst, reverse

abstract type AbstractSimpleWeightedEdge <: AbstractEdge end

struct SimpleWeightedEdge{T<:Integer, U<:Real} <: AbstractSimpleWeightedEdge
    src::T
    dst::T
    weight::U
end

SimpleWeightedEdge(t::Tuple) = SimpleWeightedEdge(t[1], t[2], t[3])
SimpleWeightedEdge(p::Pair) = SimpleWeightedEdge(p.first, p.second, zero(Float64))
SimpleWeightedEdge{T, U}(p::Pair) where T<:Integer where U <: Real = SimpleWeightedEdge(T(p.first), T(p.second), zero(U))
SimpleWeightedEdge{T, U}(t::Tuple) where T<:Integer where U <: Real = SimpleWeightedEdge(T(t[1]), T(t[2]), U(t[3]))
SimpleWeightedEdge(x, y) = SimpleWeightedEdge(x, y, zero(Float64))
eltype(e::T) where T<:AbstractSimpleWeightedEdge= eltype(src(e))

# Accessors
src(e::AbstractSimpleWeightedEdge) = e.src
dst(e::AbstractSimpleWeightedEdge) = e.dst
weight(e::AbstractSimpleWeightedEdge) = e.weight

# I/O
show(io::IO, e::AbstractSimpleWeightedEdge) = print(io, "Edge $(e.src) => $(e.dst) with weight $(e.weight)")

# Conversions
Tuple(e::AbstractSimpleWeightedEdge) = (src(e), dst(e), weight(e))

(::Type{SimpleWeightedEdge{T, U}}){T<:Integer, U<:Real}(e::AbstractSimpleWeightedEdge) = SimpleWeightedEdge{T, U}(T(e.src), T(e.dst), U(e.weight))

# Convenience functions - note that these do not use weight.
reverse(e::T) where T<:AbstractSimpleWeightedEdge = T(dst(e), src(e), weight(e))
==(e1::AbstractSimpleWeightedEdge, e2::AbstractSimpleWeightedEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2))
