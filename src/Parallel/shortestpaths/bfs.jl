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

"""
    gdistances!(g, sources, vert_level; queue_segment_size=20)
    gdistances!(g, source, vert_level; queue_segment_size=20)

Parallel implementation of [`LightGraphs.gdistances!`](@ref) with dynamic load balancing.

### Optional Arguments
- `queue_segment_size = 20`: It is the number of vertices a thread can claim from a queue
at a time. For graphs with uniform degree, a larger value of `queue_segment_size` could
improve performance.

### References
- [Avoiding Locks and Atomic Instructions in Shared-Memory Parallel BFS Using Optimistic 
Parallelization](https://www.computer.org/csdl/proceedings/ipdpsw/2013/4979/00/4979b628-abs.html).
"""
function gdistances!(
    g::AbstractGraph{T}, 
    sources::Vector{<:Integer},
    parents::Vector{T},
    vert_level::Vector{T};
    queue_segment_size::Integer=20
    ) where T <:Integer
 
    nvg = nv(g)
    n_t = nthreads()
    segment_size = convert(T, queue_segment_size) # Type stability
    fill!(vert_level, typemax(T))
    visited = zeros(Bool, nvg)

    #bitVector not thread safe
    next_level_t = [sizehint!(Vector{T}(), cld(nvg, n_t)) for _ in Base.OneTo(n_t)]
    cur_level_t = [sizehint!(Vector{T}(), cld(nvg, n_t)) for _ in Base.OneTo(n_t)]
    cur_front_t = ones(T, n_t)
    queue_explored_t = zeros(Bool, n_t)

    for s in sources    
        visited[s] = true
        vert_level[s] = zero(T)
        parents[s] = zero(T)
    end
    partition_sources!(cur_level_t, sources, queue_explored_t)
    is_cur_level_t_empty = isempty(sources)
    n_level = zero(T)

    while !is_cur_level_t_empty
        n_level += one(T)

        let n_level=n_level # let block used due to bug #15276
        @threads for thread_id in Base.OneTo(n_t)
            #Explore current level in parallel
            @inbounds next_level = next_level_t[thread_id]

            @inbounds for t_range in (thread_id:n_t, 1:(thread_id-1)), t in t_range
                queue_explored_t[t] && continue
                cur_level = cur_level_t[t]
                cur_len = length(cur_level)

                # Explore cur_level_t[t] one segment at a time.
                while true 
                    local_front = cur_front_t[t]  # Data race, but first read always succeeds
                    cur_front_t[t] += segment_size # Failure of increment is acceptable

                    (local_front > cur_len || local_front <= zero(T)) && break                    
                    while local_front <= cur_len && cur_level[local_front] != zero(T)
                        v = cur_level[local_front]
                        cur_level[local_front] = zero(T)
                        local_front += one(T)

                        # Check if v was successfully read.
                        (visited[v] && vert_level[v] == n_level-one(T)) || continue
                        for i in outneighbors(g, v)
                            # Data race, but first read on visited[i] always succeeds
                            if !visited[i]
                                vert_level[i] = n_level
                                parents[i] = v
                                #Concurrent visited[i] = true always succeeds
                                visited[i] = true
                                push!(next_level, i)
                            end
                        end
                    end   
                end
                queue_explored_t[t] = true        
            end      
        end
        end

        is_cur_level_t_empty = true
        @inbounds for t in Base.OneTo(n_t)
            cur_level_t[t], next_level_t[t] = next_level_t[t], cur_level_t[t]
            cur_front_t[t] = one(T)
            empty!(next_level_t[t])
            queue_explored_t[t] = isempty(cur_level_t[t])
            is_cur_level_t_empty = is_cur_level_t_empty && queue_explored_t[t]
        end               
    end

    return BFSResult(parents, vert_level)
end

gdistances!(g::AbstractGraph{T}, source::Integer, parents::Vector{T}, vert_level::Vector{T}; queue_segment_size::Integer=20) where T<:Integer = 
    gdistances!(g, [source,], parents, vert_level; queue_segment_size=20)

"""
    gdistances(g, sources; queue_segment_size=20)
    gdistances(g, source; queue_segment_size=20)

Parallel implementation of [`LightGraphs.gdistances!`](@ref) with dynamic load balancing.

### Optional Arguments
- `queue_segment_size = 20`: It is the number of vertices a thread can claim from a queue at a time.
For denser graphs, a smaller value of `queue_segment_size` could improve performance.

### References
- [Avoiding Locks and Atomic Instructions in Shared-Memory Parallel BFS Using Optimistic 
Parallelization](https://www.computer.org/csdl/proceedings/ipdpsw/2013/4979/00/4979b628-abs.html).
"""
gdistances(g::AbstractGraph{T}, sources::Vector{<:Integer}; queue_segment_size::Integer=20) where T<:Integer = 
    gdistances!(g, sources, Vector{T}(undef, nv(g)), Vector{T}(undef, nv(g)); queue_segment_size=queue_segment_size)

gdistances(g::AbstractGraph{T}, source::Integer; queue_segment_size::Integer=20) where T<:Integer = 
    gdistances(g, [source,]; queue_segment_size=queue_segment_size)

parallel_shortest_paths(g::AbstractGraph, sources::Vector, bs::BFS; queue_segment_size::Integer) = gdistances(g, sources, queue_segment_size)
parallel_shortest_paths(g::AbstractGraph, source::Integer, bs::BFS; queue_segment_size::Integer) = gdistances(g, [source,], queue_segment_size)

