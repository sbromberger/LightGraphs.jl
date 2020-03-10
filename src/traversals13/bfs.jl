#### REMOVE-2.0

function bfs_parents(g::AbstractGraph, s::Integer; dir = :out)
    Base.depwarn(
        "`bfs_parents` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.parents`.",
        :bfs_parents,
    )
    z = dir == :out ?
        LightGraphs.Traversals.parents(g, s, LightGraphs.Traversals.BreadthFirst()) :
        LightGraphs.Traversals.parents(
        g,
        s,
        LightGraphs.Traversals.BreadthFirst(neighborfn = inneighbors),
    )
    z[s] = s # fixing this in 2.0
    return z
end

function bfs_tree(g::AbstractGraph, s::Integer; dir = :out)
    Base.depwarn(
        "`bfs_tree` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.tree`.",
        :bfs_tree,
    )
    dir == :out ? LightGraphs.Traversals.tree(g, s, LightGraphs.Traversals.BreadthFirst()) :
    LightGraphs.Traversals.tree(
        g,
        s,
        LightGraphs.Traversals.BreadthFirst(neighborfn = inneighbors),
    )
end

function gdistances!(
    g::AbstractGraph{T},
    source,
    vert_level;
    sort_alg = QuickSort,
) where {T}
    Base.depwarn(
        "`gdistances!` has been deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.traverse_graph!` using `LightGraphs.Traversals.DistanceState`.",
        :gdistances!,
    )
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

function gdistances(g::AbstractGraph, source; sort_alg = Base.Sort.QuickSort)
    Base.depwarn(
        "`gdistances` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.distances`.",
        :gdistances,
    )
    LightGraphs.Traversals.distances(
        g,
        source,
        LightGraphs.Traversals.BreadthFirst(sort_alg = sort_alg),
    )
end

function has_path(
    g::AbstractGraph{T},
    u::Integer,
    v::Integer;
    exclude_vertices::AbstractVector = Vector{T}(),
) where {T}
    Base.depwarn(
        "`has_path` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.has_path`.",
        :has_path,
    )
    LightGraphs.Traversals.has_path(
        g,
        u,
        v,
        LightGraphs.Traversals.BreadthFirst();
        exclude_vertices = exclude_vertices,
    )
end
