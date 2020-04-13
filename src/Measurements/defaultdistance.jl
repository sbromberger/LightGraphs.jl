# used in shortest path calculations

"""
    DefaultDistance

An array-like structure that provides distance values of `1` for any `src, dst` combination.
"""
struct DefaultDistance <: AbstractMatrix{Int}
    nv::Int
    DefaultDistance(nv::Int=typemax(Int)) = new(nv)
end

DefaultDistance(nv::Integer) = DefaultDistance(Int(nv))

show(io::IO, x::DefaultDistance) = print(io, "$(x.nv) × $(x.nv) default distance matrix (value = 1)")
show(io::IO, z::MIME"text/plain", x::DefaultDistance) = show(io, x)

getindex(::DefaultDistance, s::Integer, d::Integer) = 1
getindex(::DefaultDistance, s::UnitRange, d::UnitRange) = DefaultDistance(length(s))
size(d::DefaultDistance) = (d.nv, d.nv)
transpose(d::DefaultDistance) = d
adjoint(d::DefaultDistance) = d

