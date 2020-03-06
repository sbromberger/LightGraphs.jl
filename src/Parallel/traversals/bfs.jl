#### REMOVE-2.0
const LPT = LightGraphs.Parallel.Traversals

function bfs_tree!(
        next, # Thread safe queue to add vertices to
        g::AbstractGraph, # The graph
        source::T, # Source vertex
        parents::Array{Atomic{T}} # Parents array
    ) where T<:Integer
    Base.depwarn("`Parallel.bfs_tree!` is deprecated. Equivalent functionality has been moved to `LightGraphs.Parallel.Traversals.parents`.", :bfs_tree!)
    newparents = LPT.parents(g, source)
    parents .= Atomic{T}.(newparents)
    return parents
end

@deprecate bfs_tree(g, source, nv) LPT.parents(g, source, LPT.ThreadedBreadthFirst())
@deprecate bfs_tree(g, source) LPT.parents(g, source, LPT.ThreadedBreadthFirst())
