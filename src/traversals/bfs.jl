"""
    tree(parents)

Convert a parents array into a directed graph.
"""
function tree(parents::AbstractVector{T}) where T<:Integer
    n = T(length(parents))
    t = DiGraph(n)
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
"""
bfs_parents(g::AbstractGraph, s::Integer; dir=:out) = 
    (dir == :out) ? _bfs_parents(g, s, out_neighbors) : _bfs_parents(g, s, in_neighbors)
function _bfs_parents(g::AbstractGraph, s::Integer, neighborfn::Function)
    T = eltype(g)
    Q=Vector{T}()
    parents = zeros(T, nv(g))
    seen = zeros(Bool, nv(g))
    parents[s] = s
    seen[s] = true
    push!(Q, s)
    while !isempty(Q)
        src = shift!(Q)
        for vertex in neighborfn(g, src)
            if !seen[vertex]
                push!(Q, vertex) #Push onto queue
                parents[vertex] = src
                seen[vertex] = true
            end
        end
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
bfs_tree(g::AbstractGraph, s::Integer; dir=:out) = tree(bfs_parents(g, s; dir=dir))

"""
    gdistances!(g, source, dists)

Fill `dists` with the geodesic distances of vertices in `g` from `source`.
`dists` should be a vector of length `nv(g)`. Return `dists`.
For vertices in disconnected components the default distance is -1.
"""
function gdistances!(g::AbstractGraph, source, dists)
    T = eltype(g)
    n = nv(g)
    fill!(dists, typemax(T))
    seen = zeros(Bool, n)
    queue = Vector{T}(n)
    @inbounds for i in 1:length(source)
        queue[i] = source[i]
        dists[source[i]] = 0
        seen[source[i]] = true
    end
    head = 1
    tail = length(source)
    while head <= tail
        current = queue[head]
        distance = dists[current] + 1
        head += 1
        @inbounds for j in out_neighbors(g, current)
            if !seen[j]
                dists[j] = distance
                tail += 1
                queue[tail] = j
                seen[j] = true
            end
        end
    end
    return dists
end


"""
    gdistances(g, source)

Return a vector filled with the geodesic distances of vertices in  `g` from
`source`. If `source` is a collection of vertices each element should be unique.
For vertices in disconnected components the default distance is -1.
"""
gdistances(g::AbstractGraph, source) = gdistances!(g, source, Vector{Int}(nv(g)))

"""
    has_path(g::AbstractGraph, u, v; exclude_vertices=Vector())

Return `true` if there is a path from `u to `v` in `g` (while avoiding vertices in
`exclude_vertices`) or `u == v`. Return false if there is no such path or if `u` or `v`
is in `excluded_vertices`. 
"""
function has_path(g::AbstractGraph, u::Integer, v::Integer; 
        exclude_vertices::AbstractVector=Vector{eltype(g)}())
    T = eltype(g)
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
        src = shift!(next) # get new element from queue
        for vertex in out_neighbors(g, src)
            vertex == v && return true
            if !seen[vertex]
                push!(next, vertex) # push onto queue
                seen[vertex] = true
            end
        end
    end
    return false
end
