# DFS implementation optimized from http://www.cs.nott.ac.uk/~psznza/G5BADS03/graphs2.pdf
# Depth-first visit / traversal

"""
    is_cyclic(g)

Return `true` if graph `g` contains a cycle.

See also: [`get_cycle`](@ref)

### Implementation Notes
Uses DFS.
"""
function is_cyclic end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn is_cyclic(g::::(!IsDirected)) = ne(g) > 0
@traitfn function is_cyclic(g::AG::IsDirected) where {T, AG<:AbstractGraph{T}}
    return !isempty(get_path_or_cycle(g, vertices(g), 0, true, true))
end

"""
    get_cycle(g)

Return an arbitrary cycle from graph `g` or an empty vector if `g` has
no cycle.

    get_cycle(g, v)

Return an arbitrary cycle from graph `g` which includes vertex `v` or
an empty vector if `v` is not part of any cycle in `g`.

See also: [`is_cyclic`](@ref)

### Implementation Notes
Uses DFS. The first encountered cycle is returned.
"""
function get_cycle end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function get_cycle(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}}
    ne(g) == 0 && return Vector{T}()
    e = first(edges(g))
    return [src(e), dst(e)]
end

@traitfn function get_cycle(g::AG::(!IsDirected), v::Integer) where {T, AG<:AbstractGraph{T}}
    n = neighbors(g, v)
    isempty(n) && return Vector{T}()
    return [T(v), n[1]]
end

@traitfn function get_cycle(g::AG::IsDirected) where {T, AG<:AbstractGraph{T}}
    return get_path_or_cycle(g, vertices(g), 0, true, false)
end

@traitfn function get_cycle(g::AG::IsDirected, v::Integer) where {T, AG<:AbstractGraph{T}}
    return get_path_or_cycle(g, v, v, true, false)
end

"""
    get_path(g, v, w)

Return an arbitrary path from vertex `v` to vertex `w` in graph `g` or
an empty vector if there is no path from `v` to `w`.

See also: [`has_path`](@ref)

### Implementation Notes
Uses DFS. The first encountered path is returned.
"""
function get_path(g::AbstractGraph, v::Integer, w::Integer)
    return get_path_or_cycle(g, v, w, false, false)
end

function get_path_or_cycle(g::AbstractGraph{T}, sources, target, find_cycle,
                           only_detect_cycle) where T
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
