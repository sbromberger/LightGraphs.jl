"""
    struct Euclidean <: RandomGenerator

A struct representing a graph generator for a Euclidean graph.

### Required Fields
- `points<:AbstractMatrix{<:Real}}`: a matrix of points

### Optional Parameters
- `L::Real`: used to bound the `d` dimensional box from which points are selected (default `1.0`)
- `p::Real`: an edge between vertices `i` and `j` is inserted if `norm(points[:,i]-points[:,j], p) < cutoff` (default `2.0`). If `p=2.0` the standard Euclidean distance will be used.
- `cutoff::Real`: the distance cutoff (if negative, every edge is harvested)
- `periodic::Bool`: if `true`, impose periodic boundary conditions in the box ``[0,L]^d`` (default `false`)
- `return_weights::Bool`: if `true`, constructor should return the weights matrix (default `false`)
- `return_points::Bool`: if `true`, constructor should return the points matrix (default `false)
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### Alternate Constructors
- **Required Fields**
-    - `N::Integer`: the second dimension of the points matrix
-    - `d::Integer`: the first dimension of the points matrix
- **Optional Fields**
-    - as listed above
"""
struct Euclidean{T<:Real, U<:AbstractMatrix{T}, V<:Real, W<:Real, R<:AbstractRNG} <: RandomGenerator
    points::U
    L::V
    p::W
    cutoff::T
    periodic::Bool
    return_weights::Bool
    return_points::Bool
    rng::R
    function Euclidean(points::U, L::V, p::W, cutoff::T, periodic::Bool, return_weights::Bool, return_points::Bool, rng::R) where
        {T<:Real, U<:AbstractMatrix{T}, V<:Real, W<:Real, R<:AbstractRNG}
        periodic && maximum(points) > L && throw(DomainError(maximum(points), "Some points are outside the box of size $L"))
        c = cutoff < zero(T) ? typemax(T) : cutoff
        new{T, U, V, W, R}(points, L, p, c, periodic, return_weights, return_points, rng)
    end
end

Euclidean(points::AbstractMatrix; L=1.0, p=2.0, cutoff=-1.0, periodic=false, return_weights=false, return_points=false, rng=GLOBAL_RNG) =
    Euclidean(points, L, p, cutoff, periodic, return_weights, return_points, rng)

function Euclidean(N::Int, d::Int; L=1.0, p=2.0, cutoff=-1.0, periodic=false, return_weights=false, return_points=false, rng=GLOBAL_RNG)
    points = rmul!(rand(rng, d, N), L)
    return Euclidean(points, L, p, cutoff, periodic, return_weights, return_points, rng)
end
