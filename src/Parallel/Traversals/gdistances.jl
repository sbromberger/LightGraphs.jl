function gdistances!(
    g::AbstractGraph{T}, 
    sources::Vector{<:Integer},
    vert_level::Vector{T};
    queue_segment_size::Integer=20
    ) where T <:Integer
 
    Base.depwarn("`Parallel.gdistances!` is deprecated. Equivalent functionality has been moved to `LightGraphs.Parallel.shortest_paths`.", :gdistances)
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

    return vert_level
end

gdistances!(g::AbstractGraph{T}, source::Integer, vert_level::Vector{T}; queue_segment_size::Integer=20) where T<:Integer = 
gdistances!(g, [source,], vert_level; queue_segment_size=20)

function gdistances(g::AbstractGraph{T}, sources::Vector{<:Integer}; queue_segment_size::Integer=20) where T<:Integer 
    Base.depwarn("`Parallel.gdistances` is deprecated. Equivalent functionality has been moved to `LightGraphs.Parallel.shortest_paths`.", :gdistances)
    gdistances!(g, sources, zeros(T, nv(g)), queue_segment_size=queue_segment_size)
    # Parallel.shortest_paths(g, sources, ThreadedBFS(queue_segment_size=queue_segment_size))
end

gdistances(g::AbstractGraph{T}, source::Integer; queue_segment_size::Integer=20) where T<:Integer = 
    gdistances(g, [source,]; queue_segment_size=20)
