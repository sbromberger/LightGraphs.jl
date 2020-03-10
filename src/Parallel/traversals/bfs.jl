# TODO 2.0.0: Remove this file
const LT = LightGraphs.Traversals
"""
    ThreadQueue

A thread safe queue implementation for using as the queue for BFS.
"""
struct ThreadQueue{T, N <: Integer}
    data::Vector{T}
    head::Atomic{N} #Index of the head
    tail::Atomic{N} #Index of the tail
end

function ThreadQueue(T::Type, maxlength::N) where {N <: Integer}
    q = ThreadQueue(Vector{T}(undef, maxlength), Atomic{N}(1), Atomic{N}(1))
    return q
end

function push!(q::ThreadQueue{T, N}, val::T) where {T} where {N}
    # TODO: check that head > tail
    offset = atomic_add!(q.tail, one(N))
    q.data[offset] = val
    return offset
end

function popfirst!(q::ThreadQueue{T, N}) where {T} where {N}
    # TODO: check that head < tail
    offset = atomic_add!(q.head, one(N))
    return q.data[offset]
end

function isempty(q::ThreadQueue{T, N}) where {T} where {N}
    return (q.head[] == q.tail[]) && q.head != one(N)
end

function getindex(q::ThreadQueue{T}, iter) where {T}
    return q.data[iter]
end

"""
    bfs_tree!(g, src, parents)

Provide a parallel breadth-first traversal of the graph `g` starting with source vertex `s`,
and return a parents array. The returned array is an Array of `Atomic` integers.

### Implementation Notes
This function uses `@threads` for parallelism which depends on the `JULIA_NUM_THREADS`
environment variable to decide the number of threads to use. Refer `@threads` documentation
for more details.
"""
function bfs_tree!(
    next::ThreadQueue, # Thread safe queue to add vertices to
    g::AbstractGraph, # The graph
    source::T, # Source vertex
    parents::Array{Atomic{T}}, # Parents array
) where {T <: Integer}
    Base.depwarn(
        "`Parallel.bfs_tree!` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.parents`.",
        :bfs_tree!,
    )
    p = LT.parents(g, source, LT.ThreadedBreadthFirst())
    p[source] = source # revert to old pre-2.0.0 behavior
    parents .= Atomic{T}.(p)
    return parents
end

function bfs_tree(g::AbstractGraph, source::T, nv::T) where {T <: Integer}
    next = ThreadQueue(T, nv) # Initialize threadqueue
    parents = [Atomic{T}(0) for i in 1:nv] # Create parents array
    Parallel.bfs_tree!(next, g, source, parents)
    Base.depwarn(
        "`Parallel.bfs_tree` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.parents`.",
        :bfs_tree!,
    )
    return LT.tree(g, source, LT.ThreadedBreadthFirst())
end

function bfs_tree(g::AbstractGraph, source::T) where {T <: Integer}
    nvg = nv(g)
    Parallel.bfs_tree(g, source, nvg)
end
