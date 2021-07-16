    """
    randomwalk(g, s, niter; seed=-1)

Perform a random walk on graph `g` starting at vertex `s` and continuing for
a maximum of `niter` steps. Return a vector of vertices visited in order.
"""
function randomwalk(g::AG, s::Integer, niter::Integer; seed::Int=-1) where AG <: AbstractGraph{T} where T
    s in vertices(g) || throw(BoundsError())
    rng = getRNG(seed)
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

"""
    non_backtracking_randomwalk(g, s, niter; seed=-1)

Perform a non-backtracking random walk on directed graph `g` starting at
vertex `s` and continuing for a maximum of `niter` steps. Return a
vector of vertices visited in order.
"""
function non_backtracking_randomwalk end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function non_backtracking_randomwalk(g::AG::(!IsDirected), s::Integer, niter::Integer; seed::Int=-1) where {T, AG<:AbstractGraph{T}}
    s in vertices(g) || throw(BoundsError())
    rng = getRNG(seed)
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

# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function non_backtracking_randomwalk(g::AG::IsDirected, s::Integer, niter::Integer; seed::Int=-1) where {T, AG<:AbstractGraph{T}}
    s in vertices(g) || throw(BoundsError())
    rng = getRNG(seed)
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

"""
    self_avoiding_walk(g, s, niter; seed=-1)

Perform a [self-avoiding walk](https://en.wikipedia.org/wiki/Self-avoiding_walk)
on graph `g` starting at vertex `s` and continuing for a maximum of `niter` steps.
Return a vector of vertices visited in order.
"""
function self_avoiding_walk(g::AG, s::Integer, niter::Integer; seed::Int=-1) where AG <: AbstractGraph{T} where T
    s in vertices(g) || throw(BoundsError())
    rng = getRNG(seed)
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

"""
    loop_erased_randomwalk(g, s, niter, distmx=weights(g); f=Set(), seed=-1, 
                           rng=GLOBAL_RNG)

Perform a [loop-erased random walk](https://en.wikipedia.org/wiki/Loop-erased_random_walk)
on graph `g` starting at vertex `s` and continuing until one of the following
conditions are met: (i) `niter` steps are performed, (ii) the path has no more 
places to go, (iii) or the walk reaches an element in f.

If f is specified and the final element of the walk is not in f, the function 
will throw an error.

Return a vector of vertices visited in order.
"""
function loop_erased_randomwalk(
    g::AG, s::Integer, 
    niter::Integer=max(100, nv(g)^2);
    distmx::AbstractMatrix{T}=weights(g),
    f::Union{Set{V},Vector{V}}=Set{Integer}(), 
    seed::Int=-1,
    rng::AbstractRNG=GLOBAL_RNG
)::Vector{Int} where {T <: Real, U, AG <: AbstractGraph{U}, V <: Integer}
    s in vertices(g) || throw(BoundsError())
    
    if seed >= 0
        rng = getRNG(seed)
    end
    
    visited = Vector{Integer}(undef, 1)
    visited_view = view(visited, 1:1)
    visited_view[1] = s
    i = 1
    cur_pos = 1
    while i <= niter
        cur = visited_view[cur_pos]
        if cur in f
            break
        end
        nbrs = neighbors(g, cur)
        length(nbrs) == 0 && break
        wght = [distmx[cur, n] for n in nbrs]
        v = nbrs[findfirst(cumsum(wght) .> rand(rng)*sum(wght))]
        if v in visited_view
            cur_pos = indexin(v, visited_view)[1]
            visited_view = view(visited, 1:cur_pos)
        else
            cur_pos += 1
            if length(visited) < cur_pos
                resize!(visited, min(2*cur_pos, nv(g)))
            end
            visited[cur_pos] = v
            visited_view = view(visited, 1:cur_pos)
        end
        i += 1
    end

    length(f) == 0 || visited_view[cur_pos] in f || throw(ErrorException("termiating set was not reached"))
    return visited[1:cur_pos]
end

