"""
    abstract type WalkAlgorithm

An abstract type representing a graph walking algorithm.    
"""
abstract type WalkAlgorithm end

"""
    struct RandomWalk <: WalkAlgorithm

A struct describing a random graph walk algorithm.

### Optional Arguments
- `nonbacktracking::Bool`: set to `true` if the random walk should be non-backtracking (default: `false`).
- `niter::Integer`: the number of iterations that the random walk should perform (default: `1`).
- `rng::AbstractRNG`: the random number generator to use (default: `Random.GLOBAL_RNG`).
"""
struct RandomWalk{T<:Integer, R<:AbstractRNG} <: WalkAlgorithm
    nonbacktracking::Bool
    niter::T
    rng::R
end
RandomWalk(;nonbacktracking=false, niter=1, rng=GLOBAL_RNG) = RandomWalk(nonbacktracking, niter, rng)

"""
    struct SelfAvoidingWalk <: WalkAlgorithm

A struct describing a self-avoiding graph walk algorithm.

### Optional Arguments
- `niter::Integer`: the number of iterations that the random walk should perform (default: `1`).
- `rng::AbstractRNG`: the random number generator to use (default: `Random.GLOBAL_RNG`)
"""
struct SelfAvoidingWalk{T<:Integer, R<:AbstractRNG} <: WalkAlgorithm
    niter::T
    rng::R
end
SelfAvoidingWalk(; niter=1, rng=GLOBAL_RNG) = SelfAvoidingWalk(niter, rng)

"""
    walk(g, s, alg)

Perform a graph walk on graph `g` starting at vertex `s` using [`WalkAlgorithm`](@ref) `alg`.
Return a vector of vertices visited in order.
"""
walk(g::AbstractGraph, s::Integer, alg::SelfAvoidingWalk) = self_avoiding_walk(g, s, alg.niter, alg.rng)
walk(g::AbstractGraph, s::Integer, alg::RandomWalk) =
    alg.nonbacktracking ?   non_backtracking_randomwalk(g, s, alg.niter, alg.rng) :
                            randomwalk(g, s, alg.niter, alg.rng)

function randomwalk(g::AbstractGraph{T}, s::Integer, niter::Integer, rng::AbstractRNG) where {T}
    s in vertices(g) || throw(BoundsError())
    visited = Vector{T}()
    sizehint!(visited, niter)
    currs = s
    i = 1
    while i <= niter
        push!(visited, currs)
        i += 1
        nbrs = outneighbors(g, currs)
        length(nbrs) == 0 && break
        currs = rand(rng, nbrs)
    end
    return visited[1:(i - 1)]
end

@traitfn function non_backtracking_randomwalk(g::AG::(!IsDirected), s::Integer, niter::Integer, rng::AbstractRNG) where {T, AG<:AbstractGraph{T}}
    s in vertices(g) || throw(BoundsError())
    visited = Vector{T}()
    sizehint!(visited, niter)
    currs = s
    prev = -1
    i = 1

    push!(visited, currs)
    i += 1
    nbrs = outneighbors(g, currs)
    length(nbrs) == 0 && return visited[1:(i - 1)]
    prev = currs
    currs = rand(rng, nbrs)

    while i <= niter
        push!(visited, currs)
        i += 1
        nbrs = outneighbors(g, currs)
        length(nbrs) == 1 && break
        idnext = rand(rng, 1:(length(nbrs) - 1))
        next = nbrs[idnext]
        if next == prev
            next = nbrs[end]
        end
        prev = currs
        currs = next
    end
    return visited[1:(i - 1)]
end

@traitfn function non_backtracking_randomwalk(g::AG::IsDirected, s::Integer, niter::Integer, rng::AbstractRNG) where {T, AG<:AbstractGraph{T}}
    s in vertices(g) || throw(BoundsError())
    visited = Vector{T}()
    sizehint!(visited, niter)
    currs = s
    prev = -1
    i = 1

    while i <= niter
        push!(visited, currs)
        i += 1
        nbrs = outneighbors(g, currs)
        length(nbrs) == 0 && break
        next = rand(rng, nbrs)
        if next == prev
            length(nbrs) == 1 && break
            idnext = rand(rng, 1:(length(nbrs) - 1))
            next = nbrs[idnext]
            if next == prev
                next = nbrs[end]
            end
        end
        prev = currs
        currs = next
    end
    return visited[1:(i - 1)]
end

function self_avoiding_walk(g::AG, s::Integer, niter::Integer, rng::AbstractRNG) where {T, AG<:AbstractGraph{T}}
    s in vertices(g) || throw(BoundsError())
    visited = Vector{T}()
    svisited = Set{T}()
    sizehint!(visited, niter)
    sizehint!(svisited, niter)
    currs = s
    i = 1
    while i <= niter
        push!(visited, currs)
        push!(svisited, currs)
        i += 1
        nbrs = setdiff(Set(outneighbors(g, currs)), svisited)
        length(nbrs) == 0 && break
        currs = rand(rng, collect(nbrs))
    end
    return visited[1:(i - 1)]
end
