# DFS implementation optimized from http://www.cs.nott.ac.uk/~psznza/G5BADS03/graphs2.pdf
# Depth-first visit / traversal

"""
    is_cyclic(g)

Return `true` if graph `g` contains a simple cycle. With simple cycle
is understood a cycle which repeats neither vertices nor edges.

See also: [`find_simple_cycle`, `has_simple_cycle`](@ref)

### Implementation Notes
Uses DFS.
"""
function is_cyclic(g::AbstractGraph)
    return !isempty(find_simple_path_or_cycle(g, vertices(g), 0, true, true))
end

"""
    has_simple_cycle(g, v)

Return `true` if graph `g` contains a simple cycle which includes
vertex `v`. With simple cycle is understood a cycle which
repeats neither vertices nor edges.

See also: [`is_cyclic`](@ref), [`find_simple_cycle`](@ref)
"""
function has_simple_cycle(g::AbstractGraph, v::Integer)
    return !isempty(find_simple_path_or_cycle(g, v, v, true, true))
end

"""
    find_simple_cycle(g)

Return an arbitrary simple cycle from graph `g` or an empty vector if
`g` has no simple cycle. With simple cycle is understood a cycle which
repeats neither vertices nor edges.

    find_simple_cycle(g, v)

Return an arbitrary simple cycle from graph `g` which includes vertex
`v` or an empty vector if `v` is not part of any cycle in `g`.

A non-empty return vector `c` of length `n` is guaranteed to have the
following properties:
* `c[1] == v`
* `c` has no repeated entry.
* `(c[i], c[mod1(i+1, n)])` is an edge in `g` for `i = 1:n`.
* The number of edges in the cycle is `n`.

For undirected graphs, the requirement of non-repeating edges excludes
trivial 2-cycles since they require using the same edge twice.
Directed graphs can have 2-cycles if they have an edge in each
direction. 1-cycles correspond to self-loops in the graph.

See also: [`is_cyclic`](@ref), [`has_simple_cycle`](@ref),
[`find_simple_path`](@ref)

### Implementation Notes
Uses DFS. The first encountered cycle is returned.
"""
function find_simple_cycle(g::AbstractGraph)
    return find_simple_path_or_cycle(g, vertices(g), 0, true, false)
end

function find_simple_cycle(g::AbstractGraph, v::Integer)
    return find_simple_path_or_cycle(g, v, v, true, false)
end

"""
    has_simple_path(g, v, w; accept_trivial_paths = true)

Return true if graph `g` contains a simple path from vertex `v` to
vertex `w`. With simple path is understood a path with no repeated
vertices.

In the degenerate case `v == w`, `true` is returned if and only if
`accept_trivial_paths` is `true`.

See also: [`find_simple_path`](@ref)
"""
function has_simple_path(g::AbstractGraph{T}, v::Integer, w::Integer;
                         accept_trivial_paths::Bool = true) where T
    v == w && return accept_trivial_paths
    return !isempty(find_simple_path_or_cycle(g, v, w, false, false))
end

"""
    find_simple_path(g, v, w; accept_trivial_paths = true)

Find an arbitrary simple path from vertex `v` to vertex `w` in graph
`g` and return this as a vector of the visited vertices. Return an
empty vector if there is no simple path from `v` to `w`. With simple
path is understood a path with no repeated vertices.

In the degenerate case `v == w`, the trivial path `[v]` is returned if
`accept_trivial_paths` is `true` and otherwise an empty vector is
returned.

A non-empty return vector `p` of length `n` is guaranteed to have the
following properties:
* `p[1] == v`
* `p[end] == w`
* `p` has no repeated entry.
* `(p[i], p[i+1])` is an edge in `g` for `i = 1:(n-1)`.
* The number of edges in the path is `n - 1`.

See also: [`has_simple_path`](@ref), [`find_simple_cycle`](@ref)

### Implementation Notes
Uses DFS. The first encountered path is returned.
"""
function find_simple_path(g::AbstractGraph{T}, v::Integer, w::Integer;
                          accept_trivial_paths::Bool = true) where T
    v == w && accept_trivial_paths && return T[v]
    v == w && !accept_trivial_paths && return Vector{T}()
    return find_simple_path_or_cycle(g, v, w, false, false)
end

function find_simple_path_or_cycle(g::AbstractGraph{T}, sources, target,
                                   find_cycle, only_detect_cycle) where T
    vcolor = zeros(UInt8, nv(g))
    path = Vector{T}()
    for source in sources
        vcolor[source] != 0 && continue
        push!(path, source)
        vcolor[source] = 1
        while !isempty(path)
            u = path[end]
            w = T(0)
            for n in outneighbors(g, u)
                if vcolor[n] == 0
                    w = n
                    break
                elseif vcolor[n] == 1 && find_cycle && (target == 0 || target == n)
                    if !is_directed(g) && length(path) > 1 && path[end - 1] == n
                        # This requires using the same edge in both
                        # directions, which does not yield a simple
                        # cycle.
                        continue
                    end
                    if !only_detect_cycle
                        while path[1] != n
                            popfirst!(path)
                        end
                    end
                    return path
                end
            end
            if w != 0
                push!(path, w)
                if w == target
                    return path
                end
                vcolor[w] = 1
            else
                vcolor[u] = 2
                pop!(path)
            end
        end
    end

    return path
end

# Topological sort using DFS
"""
    topological_sort_by_dfs(g)

Return a [topological sort](https://en.wikipedia.org/wiki/Topological_sorting) of a directed
graph `g` as a vector of vertices in topological order.
"""
function topological_sort_by_dfs end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function topological_sort_by_dfs(g::AG::IsDirected) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    for v in vertices(g)
        vcolor[v] != 0 && continue
        S = Vector{T}([v])
        vcolor[v] = 1
        while !isempty(S)
            u = S[end]
            w = 0
            for n in outneighbors(g, u)
                if vcolor[n] == 1
                    error("The input graph contains at least one loop.") # TODO 0.7 should we use a different error?
                elseif vcolor[n] == 0
                    w = n
                    break
                end
            end
            if w != 0
                vcolor[w] = 1
                push!(S, w)
            else
                vcolor[u] = 2
                push!(verts, u)
                pop!(S)
            end
        end
    end
    return reverse(verts)
end

"""
    dfs_tree(g, s)

Return an ordered vector of vertices representing a directed acyclic graph based on
depth-first traversal of the graph `g` starting with source vertex `s`.
"""
dfs_tree(g::AbstractGraph, s::Integer; dir=:out) = tree(dfs_parents(g, s; dir=dir))

"""
    dfs_parents(g, s[; dir=:out])

Perform a depth-first search of graph `g` starting from vertex `s`.
Return a vector of parent vertices indexed by vertex. If `dir` is specified,
use the corresponding edge direction (`:in` and `:out` are acceptable values).

### Implementation Notes
This version of DFS is iterative.
"""
dfs_parents(g::AbstractGraph, s::Integer; dir=:out) =
(dir == :out) ? _dfs_parents(g, s, outneighbors) : _dfs_parents(g, s, inneighbors)

function _dfs_parents(g::AbstractGraph{T}, s::Integer, neighborfn::Function) where T
    parents = zeros(T, nv(g))

    seen = zeros(Bool, nv(g))
    S = Vector{T}([s])
    seen[s] = true
    parents[s] = s
    while !isempty(S)
        v = S[end]
        u = 0
        for n in neighborfn(g, v)
            if !seen[n]
                u = n
                break
            end
        end
        if u == 0
            pop!(S)
        else
            seen[u] = true
            push!(S, u)
            parents[u] = v
        end
    end
    return parents
end
