"""
    ThreadedBreadthFirst{F} <: ThreadedTraversalAlgorithm

Struct representing a threaded version of a Breadth First traversal algorithm with dynamic load balancing.

### Optional Arguments
- `queue_segment_size::Int`: the number of vertices a thread can claim from a queue
at a time (default `20`). For graphs with uniform degree, a larger value of
`queue_segment_size` may improve performance.
- `neighborfn::Function`: the function to use to compute the neighbors of a vertex (default [`outneighbors`](@ref)).

### References
- [Avoiding Locks and Atomic Instructions in Shared-Memory Parallel BFS Using Optimistic 
Parallelization](https://www.computer.org/csdl/proceedings/ipdpsw/2013/4979/00/4979b628-abs.html).
"""
struct ThreadedBreadthFirst{F<:Function} <: ThreadedTraversalAlgorithm
    queue_segment_size::Int
    neighborfn::F
end

ThreadedBreadthFirst(;queue_segment_size=20, neighborfn=outneighbors) = ThreadedBreadthFirst(queue_segment_size, neighborfn)

"""
    partition_sources!(queue_list, sources)

Partition `sources` using [`LightGraphs.unweighted_contiguous_partition`](@ref) and place
the i^{th} partition  into `queue_list[i]` and set to empty_list[i] to true if the 
i^{th} partition is empty.
"""
function partition_sources!(
    queue_list::Vector{Vector{T}},
    sources::Vector{<:Integer},
    empty_list::Vector{Bool}
    ) where T<:Integer
    
    partitions = LightGraphs.unweighted_contiguous_partition(length(sources), length(queue_list))
    for (i, p) in enumerate(partitions)
        append!(queue_list[i], sources[p])
        empty_list[i] = isempty(p)
    end
end

function traverse_graph!(
    g::AbstractGraph{U},
    ss::AbstractVector,
    alg::ThreadedBreadthFirst,
    state::TraversalState) where {U<:Integer}
 
    n = nv(g)
    n_t = nthreads()
    segment_size = U(alg.queue_segment_size) # Type stability
    # vert_level = fill(typemax(U), n)
    visited = zeros(Bool, n) #bitVector not thread safe
    next_level_t = [sizehint!(Vector{U}(), cld(n, n_t)) for _ in Base.OneTo(n_t)]
    cur_level_t = [sizehint!(Vector{U}(), cld(n, n_t)) for _ in Base.OneTo(n_t)]
    cur_front_t = ones(U, n_t)
    retvals_t = ones(Bool, n_t)
    queue_explored_t = zeros(Bool, n_t)

    preinitfn!(state, visited) || return false
    @inbounds for s in ss
        us = U(s)
        visited[s] = true
        # vert_level[s] = zero(U)
        initfn!(state, us) || return false
    end
    partition_sources!(cur_level_t, ss, queue_explored_t)
    is_cur_level_t_empty = isempty(ss)
    n_level = zero(U)

    while !is_cur_level_t_empty
        n_level += one(U)

        let n_level=n_level # let block used due to bug #15276
        @threads for thread_id in Base.OneTo(n_t)
            #Explore current level in parallel
            @inbounds next_level = next_level_t[thread_id]

            @inbounds for t_range in (thread_id:n_t, 1:(thread_id-1)), t in t_range
                all(retvals_t) || break
                queue_explored_t[t] && continue
                cur_level = cur_level_t[t]
                cur_len = length(cur_level)

                # Explore cur_level_t[t] one segment at a time.
                while true 
                    all(retvals_t) || break
                    local_front = cur_front_t[t]  # Data race, but first read always succeeds
                    cur_front_t[t] += segment_size # Failure of increment is acceptable

                    (local_front > cur_len || local_front <= zero(U)) && break
                    while local_front <= cur_len && cur_level[local_front] != zero(U)
                        v = cur_level[local_front]
                        cur_level[local_front] = zero(U)
                        local_front += one(U)

                        (retvals_t[t] &= previsitfn!(state, v, t)) || break
                        # Check if v was successfully read.
                        visited[v] || continue
                        # (visited[v] && vert_level[v] == n_level-one(U)) || continue
                        for i in alg.neighborfn(g, v)
                            (retvals_t[t] &= visitfn!(state, v, i, t)) || return false
                            # Data race, but first read on visited[i] always succeeds
                            if !visited[i]
                                (retvals_t[t] &= newvisitfn!(state, v, i, t)) || break
                                # vert_level[i] = n_level
                                #Concurrent visited[i] = true always succeeds
                                visited[i] = true
                                push!(next_level, i)
                            end
                        end
                        (retvals_t[t] &= postvisitfn!(state, v, t)) || break
                    end   
                end
                queue_explored_t[t] = true        
            end      
        end # @threads
        end #let
        postlevelfn!(state) || return false

        is_cur_level_t_empty = true
        @inbounds for t in Base.OneTo(n_t)
            cur_level_t[t], next_level_t[t] = next_level_t[t], cur_level_t[t]
            cur_front_t[t] = one(U)
            empty!(next_level_t[t])
            queue_explored_t[t] = isempty(cur_level_t[t])
            is_cur_level_t_empty = is_cur_level_t_empty && queue_explored_t[t]
        end               
    end
    return all(retvals_t)
end

# initfn! and postlevelfn! are inherited from the non-threaded version.
# we only override newvisitfn! here because the threaded version requires
# an additional parameter `t` which is the threadID. `distances` doesn't need it
# but other algorithms might.

@inline function newvisitfn!(s::LightGraphs.Traversals.DistanceState, u, v, t::Integer)
    s.distances[v] = s.n_level
    return true
end

distances(g::AbstractGraph{T}, s, alg::ThreadedBreadthFirst) where T =
    distances!(g, s, alg, LightGraphs.Traversals.DistanceState(fill(typemax(T), nv(g)), one(T)))

mutable struct ThreadedPathState{T<:Integer} <: TraversalState
    u::T
    v::T
    exclude_vertices::Vector{T}
    vertices_in_exclude::Bool
end

