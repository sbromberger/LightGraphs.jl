# TODO 2.0.0: Remove this file
function gdistances!(
    g::AbstractGraph{T}, 
    sources,
    vert_level::Vector{T};
    queue_segment_size::Integer=20
    ) where T <:Integer
 
    Base.depwarn("`Parallel.gdistances!` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.distances`.", :gdistances!)
    d = LightGraphs.Traversals.distances(g, sources, LightGraphs.Traversals.ThreadedBreadthFirst(queue_segment_size=queue_segment_size))
    vert_level .= T.(d)
    return vert_level
end

function gdistances(g::AbstractGraph, ss; queue_segment_size=20)
    Base.depwarn("`Parallel.gdistances` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.distances`.", :gdistances)
    LightGraphs.Traversals.distances(g, ss, LightGraphs.Traversals.ThreadedBreadthFirst(queue_segment_size=queue_segment_size))
end
