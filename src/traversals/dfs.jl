# DFS implementation optimized from http://www.cs.nott.ac.uk/~psznza/G5BADS03/graphs2.pdf
# Depth-first visit / traversal

"""
    is_cyclic(g)

Return `true` if graph `g` contains a cycle.

### Implementation Notes
Uses DFS.
"""
function is_cyclic end
@traitfn is_cyclic(g::::(!IsDirected)) = ne(g) > 0
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function is_cyclic(g::AG::IsDirected) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    for v in vertices(g)
        vcolor[v] != 0 && continue
        S = Vector{T}([v])
        vcolor[v] = 1
        while !isempty(S)
            u = S[end]
            w = 0
            for n in outneighbors(g, u)
                if vcolor[n] == 1
                    return true
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
                pop!(S)
            end
        end
    end
    return false
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

"""
    has_path(g::AbstractGraph, u, v; exclude_vertices=Vector())

Return `true` if there is a path from `u` to `v` in `g` (while avoiding vertices in
`exclude_vertices`) or `u == v`. Return false if there is no such path or if `u` or `v`
is in `excluded_vertices`. 

### Implementation Notes
`has_path(g, v, v)` will return `false` unless there is an explicit
self-loop defined on vertex `v`. This is a change from previous
versions.
"""
function has_path end

@traitfn function has_path(g::AG::IsDirected, src::Integer, target::Integer;
                           exclude_vertices::AbstractVector = Vector{Int}()) where {T , AG <: AbstractGraph{T}}
    seen = zeros(Bool, nv(g))
    @inbounds for ve in exclude_vertices
        seen[ve] = true
    end
    (seen[src] || seen[target]) && return false

    # Idea here is to start from the neighbours of src and see whether BFS will reach a target
    stack = deepcopy(outneighbors(g, src))
    @inbounds while !isempty(stack)
        curr = pop!(stack) # get new element from stack
        seen[curr] && continue
        curr == target && return true
        seen[curr] = true
        for vertex in outneighbors(g, curr)
            vertex == target && return true
            if !seen[vertex]
                push!(stack, vertex) # push onto stack
            end
        end
    end
    return false
end

@traitfn function has_path(g::AG::(!IsDirected), src::Integer, target::Integer;
                           exclude_vertices::AbstractVector = Vector{Int}()) where {T, AG <: AbstractGraph{T}}
    seen = zeros(Bool, nv(g))
    @inbounds for ve in exclude_vertices
        seen[ve] = true
    end
    (seen[src] || seen[target]) && return false

    # Same idea as directed case, but we ensure no backtracking from the edge we come from.
    # We use Depth-First Search instead to perform this
    stack = Vector{T}()
    parents = Vector{T}()
    for v in outneighbors(g, src)
        push!(stack, v)
        push!(parents, src)
    end

    @inbounds while !isempty(stack)
        curr = pop!(stack) # get new element from stack
        prev = pop!(parents)
        seen[curr] && continue
        curr == target && return true
        seen[curr] = true
        for vertex in outneighbors(g, curr)
            vertex == prev && continue
            vertex == target && return true
            if !seen[vertex]
                push!(stack, vertex) # push onto queue
                push!(parents, curr)
            end
        end
    end
    return false
end

