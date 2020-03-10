# TODO 2.0.0: Remove this file
@deprecate is_cyclic LightGraphs.Traversals.is_cyclic
# Topological sort using DFS
@traitfn function topological_sort_by_dfs(g::AG::IsDirected) where {T,AG<:AbstractGraph{T}}
    Base.depwarn(
        "`topological_sort_by_dfs` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.topological_sort`.",
        :toplogical_sort_by_dfs,
    )
    LightGraphs.Traversals.topological_sort(g, LightGraphs.Traversals.DepthFirst())
end

function dfs_tree(g::AbstractGraph, s::Integer; dir = :out)
    Base.depwarn(
        "`dfs_tree` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.tree`.",
        :dfs_tree,
    )
    z = dir == :out ?
        LightGraphs.Traversals.tree(g, s, LightGraphs.Traversals.DepthFirst()) :
        LightGraphs.Traversals.tree(g, s, LightGraphs.Traversals.DepthFirst(inneighbors))
    # fixed in 2.0
    z
end


function dfs_parents(g::AbstractGraph, s::Integer; dir = :out)
    Base.depwarn(
        "`dfs_parents` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.parents`.",
        :dfs_parents,
    )
    dir == :out ?
    LightGraphs.Traversals.parents(g, s, LightGraphs.Traversals.DepthFirst()) :
    LightGraphs.Traversals.parents(g, s, LightGraphs.Traversals.DepthFirst(inneighbors))
end
