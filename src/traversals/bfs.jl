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
function _bfs_parents(g::AbstractGraph{T}, s::Integer, neighborfn::Function) where T
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
function gdistances!(g::AbstractGraph{T}, source, dists) where T
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

function gdistances2!(g::AbstractGraph{T}, source, vert_level) where T
    n = nv(g)
    visited = falses(n)
    n_level = T(2)
    cur_level = Vector{T}()
    sizehint!(cur_level, n)
    next_level = Vector{T}()
    sizehint!(next_level, n)
    vert_level[source] = zero(T)
    visited[source] = true

    push!(cur_level, source)
    while !isempty(cur_level)
        @inbounds for v in cur_level
            @simd for i in out_neighbors(g, v)
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
        sort!(cur_level)
    end
    return vert_level
end

function gdist2(g::AbstractGraph{T}, source) where T
    dists = zeros(T, nv(g))
    gdistances2!(g, source, dists)
end


function gdistances3!(g::AbstractGraph{T}, source, dists) where T
    n = nv(g)
    fill!(dists, typemax(T))
    seen = zeros(Bool, n)
    queue = Vector{T}(n)
    @inbounds @simd for i in 1:length(source)
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
        @inbounds @simd for j in out_neighbors(g, current)
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


function gdist3(g::AbstractGraph{T}, source) where T 
    dists = zeros(T, nv(g))
    gdistances3!(g, source, dists)
end
    
"""
    gdistances(g, source)

Return a vector filled with the geodesic distances of vertices in  `g` from
`source`. If `source` is a collection of vertices each element should be unique.
For vertices in disconnected components the default distance is -1.
"""
gdistances(g::AbstractGraph{T}, source) where T = gdistances!(g, source, Vector{T}(nv(g)))

"""
    has_path(g::AbstractGraph, u, v; exclude_vertices=Vector())

Return `true` if there is a path from `u to `v` in `g` (while avoiding vertices in
`exclude_vertices`) or `u == v`. Return false if there is no such path or if `u` or `v`
is in `excluded_vertices`. 
"""
function has_path(g::AbstractGraph{T}, u::Integer, v::Integer; 
        exclude_vertices::AbstractVector=Vector{T}()) where T
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
