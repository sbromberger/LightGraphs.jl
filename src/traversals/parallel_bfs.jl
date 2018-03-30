# Parts of this code was written by @jpfairbanks.

# Parallel Breadth-first search / traversal using a frontier based parallelized
# approach.

#################################################
#
# Parallel frontier based Breadth-first search approach
#
#################################################

using Base.Threads

import Base: push!, popfirst!, isempty, getindex

export bfs_tree, LevelSynchronousBFS

struct LevelSynchronousBFS end

"""
    ThreadQueue

A thread safe queue implementation for using as the queue for BFS.
"""
struct ThreadQueue{T,N<:Integer}
    data::Vector{T}
    head::Atomic{N} #Index of the head
    tail::Atomic{N} #Index of the tail
end

function ThreadQueue(T::Type, maxlength::N) where N <: Integer
    q = ThreadQueue(Vector{T}(undef, maxlength), Atomic{N}(1), Atomic{N}(1))
    return q
end

function push!(q::ThreadQueue{T,N}, val::T) where T where N
    # TODO: check that head > tail
    offset = atomic_add!(q.tail, one(N))
    q.data[offset] = val
    return offset
end

function popfirst!(q::ThreadQueue{T,N}) where T where N
    # TODO: check that head < tail
    offset = atomic_add!(q.head, one(N))
    return q.data[offset]
end

function isempty(q::ThreadQueue{T,N}) where T where N
    return (q.head[] == q.tail[]) && q.head != one(N)
end

function getindex(q::ThreadQueue{T}, iter) where T
    return q.data[iter]
end

# Traverses the vertices in the queue and adds newly found successors to the queue.
function bfskernel(
        alg::LevelSynchronousBFS,
        next::ThreadQueue, # Thread safe queue to add vertices to
        g::AbstractGraph, # The graph
        parents::Array{Atomic{T}}, # Parents array
        level::Array{T} # Vertices in the current frontier
    ) where T <: Integer
    @threads for src in level
        vertexneighbors = neighbors(g, src) # Get the neighbors of the vertex
        for vertex in vertexneighbors
            # Atomically check and set parent value if not set yet.
            parent = atomic_cas!(parents[vertex], zero(T), src)
            if parent == 0
                push!(next, vertex) #Push onto queue if newly found
            end
        end
    end
end

"""
    bfs_tree!(LevelSynchronousBFS(), g, src, parents)

Provide a parallel breadth-first traversal of the graph `g` starting with source vertex `s`,
and return a parents array. The returned array is an Array of `Atomic` integers.

### Implementation Notes
This function uses `@threads` for parallelism which depends on the `JULIA_NUM_THREADS`
environment variable to decide the number of threads to use. Refer `@threads` documentation
for more details.
"""
function bfs_tree!(
        alg::LevelSynchronousBFS,
        next::ThreadQueue, # Thread safe queue to add vertices to
        g::AbstractGraph, # The graph
        source::T, # Source vertex
        parents::Array{Atomic{T}} # Parents array
    ) where T<:Integer
    parents[source][] = source # Set source to source
    push!(next, source) # Add source to the queue
    while !isempty(next)
        level = next[next.head[]:(next.tail[] - 1)] # Get vertices in the frontier
        next.head[] = next.tail[] # reset the queue
        bfskernel(alg, next, g, parents, level) # Find new frontier
    end
    return parents
end

"""
    bfs_tree(LevelSynchronousBFS(), g, s, nv)

Provide a parallel breadth-first traversal of the graph `g` starting with source vertex `s`,
and return a directed acyclic graph of vertices in the order they were discovered
using a frontier based parallel approach.

### Implementation Notes
This function uses `@threads` for parallelism which depends on the `JULIA_NUM_THREADS`
environment variable to decide the number of threads to use. Refer `@threads` documentation
for more details.
This function is a high level wrapper around [`LightGraphs.bfs_tree!`](@ref); use that function for more performance.
"""
function bfs_tree(alg::LevelSynchronousBFS, g::AbstractGraph, source::T, nv::T) where T <: Integer
    next = ThreadQueue(T, nv) # Initialize threadqueue
    parents = [Atomic{T}(0) for i = 1:nv] # Create parents array
    bfs_tree!(alg, next, g, source, parents)
    tree([i[] for i in parents])
end

function bfs_tree(alg::LevelSynchronousBFS, g::AbstractGraph, source::T) where T <: Integer
    nvg = nv(g)
    bfs_tree(alg, g, source, nvg)
end
