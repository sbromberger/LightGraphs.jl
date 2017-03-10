module SimpleEdges

import Base: Pair, Tuple, show, ==
import LightGraphs: AbstractEdge, src, dst, reverse
export AbstractSimpleEdge, SimpleEdge

abstract AbstractSimpleEdge <: AbstractEdge

immutable SimpleEdge <: AbstractSimpleEdge
    src::Int
    dst::Int
end

# Accessors
src{T<:AbstractSimpleEdge}(e::T) = e.src
dst{T<:AbstractSimpleEdge}(e::T) = e.dst

# I/O
show{T<:AbstractSimpleEdge}(io::IO, e::T) = print(io, "Edge $(e.src) => $(e.dst)")

# Conversions
Pair{T<:AbstractSimpleEdge}(e::T) = Pair(src(e), dst(e))
Tuple{T<:AbstractSimpleEdge}(e::T) = (src(e), dst(e))

# Convenience functions
reverse{T<:AbstractSimpleEdge}(e::T) = T(dst(e), src(e))
=={T<:AbstractSimpleEdge}(e1::T, e2::T) = (src(e1) == src(e2) && dst(e1) == dst(e2))

end
