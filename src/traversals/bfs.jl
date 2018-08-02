### DEVELOPERS NOTE: BFS optimization experiments are typically
### prototyped in gdistances!, since it's one of the simplest
### BFS implementations.

"""
    tree(parents)

Convert a parents array into a directed graph.
"""
function tree(parents::AbstractVector{T}) where T <: Integer
    n = T(length(parents))
    t = DiGraph{T}(n)
    for (v, u) in enumerate(parents)
        if u > zero(T)  && u != v
            add_edge!(t, u, v)
        end
    end
    return t
end

"""
    bfs_parents(g, s[; dir=:out])

Perform a breadth-first search of graph `g` starting from vertex `s`.
Return a vector of parent vertices indexed by vertex. If `dir` is specified,
use the corresponding edge direction (`:in` and `:out` are acceptable values).


### Performance
This implementation is designed to perform well on large graphs. There are
implementations which are marginally faster in practice for smaller graphs,
but the performance improvements using this implementation on large graphs
can be significant.
"""
bfs_parents(g::AbstractGraph, s::Integer; dir = :out) =
    (dir == :out) ? _bfs_parents(g, s, outneighbors) : _bfs_parents(g, s, inneighbors)

function _bfs_parents(g::AbstractGraph{T}, source, neighborfn::Function) where T
    n = nv(g)
    visited = falses(n)
    parents = zeros(T, nv(g))
    cur_level = Vector{T}()
    sizehint!(cur_level, n)
    next_level = Vector{T}()
    sizehint!(next_level, n)
    @inbounds for s in source
        visited[s] = true
        push!(cur_level, s)
        parents[s] = s
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            @inbounds @simd for i in  neighborfn(g, v)
                if !visited[i]
                    push!(next_level, i)
                    parents[i] = v
                    visited[i] = true
                end
            end
        end
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level)
    end
    return parents
end

"""
    bfs_tree(g, s[; dir=:out])

Provide a breadth-first traversal of the graph `g` starting with source vertex `s`,
and return a directed acyclic graph of vertices in the order they were discovered.
If `dir` is specified, use the corresponding edge direction (`:in` and `:out` are
acceptable values).
"""
bfs_tree(g::AbstractGraph, s::Integer; dir = :out) = tree(bfs_parents(g, s; dir = dir))

"""
    gdistances!(g, source, dists; sort_alg=QuickSort)

Fill `dists` with the geodesic distances of vertices in `g` from source vertex (or
collection of vertices) `source`. `dists` should be a vector of length `nv(g)`
filled with `typemax(T)`. Return `dists`.

For vertices in disconnected components the default distance is `typemax(T)`.

An optional sorting algorithm may be specified (see Performance section).

### Performance
`gdistances` uses `QuickSort` internally for its default sorting algorithm, since it performs
the best of the algorithms built into Julia Base. However, passing a `RadixSort` (available via
[SortingAlgorithms.jl](https://github.com/JuliaCollections/SortingAlgorithms.jl)) will provide
significant performance improvements on larger graphs.
"""
function gdistances!(g::AbstractGraph{T}, source, vert_level; sort_alg = QuickSort) where T
    length(source) == 0 && return vert_level 
    n = nv(g)
    visited = falses(n)
    n_level = one(T)
    cur_level = Vector{T}()
    sizehint!(cur_level, n)
    next_level = Vector{T}()
    sizehint!(next_level, n)
    @inbounds for s in source
        vert_level[s] = zero(T)
        visited[s] = true
        push!(cur_level, s)
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            @inbounds @simd for i in outneighbors(g, v)
                if !visited[i]
                    push!(next_level, i)
                    vert_level[i] = n_level
                    visited[i] = true
                end
            end
        end
        n_level += one(T)
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level, alg = sort_alg)
    end
    return vert_level
end

"""
    gdistances(g, source; sort_alg=QuickSort)

Return a vector filled with the geodesic distances of vertices in  `g` from
`source`. If `source` is a collection of vertices each element should be unique.
For vertices in disconnected components the default distance is `typemax(T)`.

An optional sorting algorithm may be specified (see Performance section).

### Performance
`gdistances` uses `QuickSort` internally for its default sorting algorithm, since it performs
the best of the algorithms built into Julia Base. However, passing a `RadixSort` (available via
[SortingAlgorithms.jl](https://github.com/JuliaCollections/SortingAlgorithms.jl)) will provide
significant performance improvements on larger graphs.
"""
gdistances(g::AbstractGraph{T}, source; sort_alg = Base.Sort.QuickSort) where T = gdistances!(g, source, fill(typemax(T), nv(g)); sort_alg = sort_alg)

"""
    has_path(g::AbstractGraph, u, v; exclude_vertices=Vector())

Return `true` if there is a path from `u` to `v` in `g` (while avoiding vertices in
`exclude_vertices`) or `u == v`. Return false if there is no such path or if `u` or `v`
is in `excluded_vertices`.
"""
function has_path(g::AbstractGraph{T}, u::Integer, v::Integer;
        exclude_vertices::AbstractVector = Vector{T}()) where T
    seen = zeros(Bool, nv(g))
    for ve in exclude_vertices # mark excluded vertices as seen
        seen[ve] = true
    end
    (seen[u] || seen[v]) && return false
    u == v && return true # cannot be separated
    next = Vector{T}()
    push!(next, u)
    seen[u] = true
    while !isempty(next)
        src = popfirst!(next) # get new element from queue
        for vertex in outneighbors(g, src)
            vertex == v && return true
            if !seen[vertex]
                push!(next, vertex) # push onto queue
                seen[vertex] = true
            end
        end
    end
    return false
end
