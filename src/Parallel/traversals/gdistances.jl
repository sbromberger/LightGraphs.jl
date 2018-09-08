using Base.Threads

"""
    partition_sources!(queue_list, rear_list, sources)

Partition `sources` using [`LightGraphs.unweighted_contiguous_partition`](@ref), place
the i<sup>th</sup> partition  into `queue_list[i]` and set `rear_list[i]` to length 
of the i<sup>th</sup> partition.
"""
function partition_sources!(
    queue_list::Vector{Vector{T}},
    rear_list::Vector{T}, 
    sources::Vector{<:Integer}
    ) where T<:Integer
    
    partitions = LightGraphs.unweighted_contiguous_partition(length(sources), length(rear_list))
    for (i, p) in enumerate(partitions)
        cur_level = queue_list[i]
        for (j, ind) in enumerate(p)
            cur_level[j] = sources[ind]
        end
        rear_list[i] = length(p)
    end
end

"""
    gdistances!(g, sources, vert_level; queue_segment_size=20)
    gdistances!(g, source, vert_level; queue_segment_size=20)

Parallel implementation of [`LightGraphs.gdistances!`](@ref) with dynamic load balancing.

### Performance
Memory: `2*nthreads()*nv(g)*sizeof(eltype(g))`

### Optional Arguments
- `queue_segment_size = 20`: It is the number of vertices a thread can claim from a queue at a time.
For denser graphs, a smaller value of `queue_segment_size` could improve performance.

### References
- [Avoiding Locks and Atomic Instructions in Shared-Memory Parallel BFS Using Optimistic 
Parallelization](https://www.computer.org/csdl/proceedings/ipdpsw/2013/4979/00/4979b628-abs.html).
"""
function gdistances!(
    g::AbstractGraph{T}, 
    sources::Vector{<:Integer},
    vert_level::Vector{T};
    queue_segment_size::Integer=20
    ) where T <:Integer
 
    n = nv(g)
    n_t = nthreads()
    segment_size = convert(T, queue_segment_size) # Type stability

    #visited = falses(n)
    visited = zeros(Bool, n)
    fill!(vert_level, typemax(T))

    # push! is not thread safe.
    # Memory overhead could be reduced.
    # End of queue is marked with 0
    next_level_t = [zeros(T, n+1) for _ in 1:n_t]
    cur_level_t = [zeros(T, n+1) for _ in 1:n_t]

    next_rear_t = Vector{T}(undef, n_t)
    cur_rear_t = Vector{T}(undef, n_t)
    cur_front_t = ones(T, n_t)

    for s in sources    
        visited[s] = true
        vert_level[s] = zero(T)
    end
   
    partition_sources!(cur_level_t, cur_rear_t, sources)

    n_level = one(T)
    is_cur_level_t_empty = isempty(sources)


    while !is_cur_level_t_empty

        # let block used due to bug #15276
        let n_level=n_level        
        @threads for thread_id in 1:n_t
            @inbounds next_level = next_level_t[thread_id]
            @inbounds next_rear = zero(T)

            local_n_level = n_level # For efficiency

            #Iterate over next_level_t, starting with next_level_t[thread_id]
            @inbounds for t_it in 1:n_t
                t = mod(t_it+thread_id-2, n_t)+1 # t = t_self to n_t, 1 to t_self-1

                cur_level = cur_level_t[t]
                cur_rear = cur_rear_t[t]

                # Explore cur_level_t[t] one segment at a time.
                while true 
                    local_front = cur_front_t[t]  # Data race, but first read always succeeds
                    cur_front_t[t] += segment_size # Failure of increment is acceptable

                    (local_front > cur_rear || local_front <= zero(T)) && break
                    
                    # Explore cur_level until it hits a 0
                    while cur_level[local_front] != zero(T)
                        v = cur_level[local_front]
                        cur_level[local_front] = zero(T)
                        local_front += one(T)

                        # Check if v was correctly read.
                        (visited[v] && vert_level[v] == local_n_level-one(T)) || continue

                        for i in outneighbors(g, v)
                            # Data race, but first read on visited always succeeds
                            if !visited[i]
                                vert_level[i] = local_n_level
                                visited[i] = true
                                next_rear+=one(T)
                                next_level[next_rear] = i
                            end
                        end
                    end   
                end        
            end      
            @inbounds next_rear_t[thread_id] = next_rear 
        end
        end
        is_cur_level_t_empty = true
        @inbounds for t in 1:n_t
            cur_rear_t[t], next_rear_t[t] = next_rear_t[t], cur_rear_t[t]
            cur_level_t[t], next_level_t[t] = next_level_t[t], cur_level_t[t]

            cur_front_t[t] = one(T) 
            is_cur_level_t_empty = is_cur_level_t_empty && (cur_rear_t[t] == zero(T))
        end            

        n_level += one(T)       
    end

    return vert_level
end

gdistances!(g::AbstractGraph{T}, source::Integer, vert_level::Vector{T}; queue_segment_size::Integer=20) where T<:Integer = 
gdistances!(g, [source,], vert_level; queue_segment_size=20)

"""
    gdistances(g, sources; queue_segment_size=20)
    gdistances(g, source; queue_segment_size=20)

Parallel implementation of [`LightGraphs.gdistances!`](@ref) with dynamic load balancing.

### Performance
Memory: `2*nthreads()*nv(g)*sizeof(eltype(g))`

### Optional Arguments
- `queue_segment_size = 20`: It is the number of vertices a thread can claim from a queue at a time.
For denser graphs, a smaller value of `queue_segment_size` could improve performance.

### References
- [Avoiding Locks and Atomic Instructions in Shared-Memory Parallel BFS Using Optimistic 
Parallelization](https://www.computer.org/csdl/proceedings/ipdpsw/2013/4979/00/4979b628-abs.html).
"""
gdistances(g::AbstractGraph{T}, sources::Vector{<:Integer}; queue_segment_size::Integer=20) where T<:Integer = 
gdistances!(g, sources, Vector{T}(undef, nv(g)); queue_segment_size=20)

gdistances(g::AbstractGraph{T}, source::Integer; queue_segment_size::Integer=20) where T<:Integer = 
gdistances!(g, [source,], Vector{T}(undef, nv(g)); queue_segment_size=20)