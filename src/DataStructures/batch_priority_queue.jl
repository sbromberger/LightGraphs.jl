import DataStructures: dequeue!, dequeue_pair!, enqueue!, peek, percolate_up!
import Base: isempty

using Base: Ordering, Forward, lt

export BatchPriorityQueue, batch_decrease_key!, peek, dequeue!, dequeue_pair!, peek, isempty

mutable struct BatchPriorityQueue{K,V,O}
    # Binary heap of (element, priority) pairs.
    num_universe::K     #vertices(g)
    num_threads::Integer    #nthreads()
    pqs::Vector{PriorityQueue{K,V,O}}
    best_pq_ind::Integer
    o::Ordering
end

function BatchPriorityQueue(
    num_universe::K,
    V::DataType,
    num_threads::Integer=nthreads(),
    o::Ordering=Forward
    ) where K<:Integer

    pqs = [PriorityQueue{K, V}(o) for _ in 1:num_threads]

    max_size = cld(num_universe, num_threads)
    @inbounds for i in 1:num_threads
        sizehint!(pqs[i].xs, max_size) #Reallocation is not thread-safe
        sizehint!(pqs[i].index, max_size)
    end

    return BatchPriorityQueue(num_universe, num_threads, pqs, 0, o)
end

function batch_decrease_key!(
    bpq::BatchPriorityQueue{K, V}, 
    key_list::Vector{K}, 
    key_to_val::Vector{V},
    ) where K where V

    @threads for thread_id in 1:(bpq.num_threads)
        @inbounds pq = bpq.pqs[thread_id]

        @inbounds for k in key_list
            (mod(k, bpq.num_threads)+1 == thread_id) || continue
            
            ind = pq.index[k]
            pq.xs[ind] = Pair{K, V}(k, key_to_val[k])
            percolate_up!(pq, ind)
        end
    end
end



#=
function batch_push!(
    bpq::BatchPriorityQueue{K, V}, 
    keys::Vector{K}, 
    vals::Vector{V},
    len_batch::Integer = min(length(keys), length(vals))
    ) where K where V

#=
    @threads for thread_id in 1:(bpq.num_threads)
        @inbounds local_pq = bpq.pqs[thread_id]
        pq_id = thread_id-1

        @inbounds for i in 1:len_batch
            if pq_id == mod(keys[i], bpq.num_threads)
                local_pq[keys[i]] = vals[i]
            end
        end
    end
=#

    @inbounds for i in 1:len_batch
        bpq.pqs[mod(keys[i], bpq.num_threads)+1][keys[i]] = vals[i]
    end


    ind = 0
    best = (bpq.o == Forward ? typemax(V) : typemin(V))
    @inbounds for (i, pq) in enumerate(bpq.pqs)
        if !isempty(pq) && lt(bpq.o, peek(pq).second, best)
            ind = i
            best = peek(pq).second
        end
    end
    bpq.best_pq_ind = ind

end
=#

#=
function ind_next(bpq::BatchPriorityQueue{K, V}) where K where V
    ind = 0
    best = (bpq.o == Forward ? typemax(V) : typemin(V))
    @inbounds for (i, pq) in enumerate(bpq.pqs)
        if !isempty(pq) && lt(bpq.o, peek(pq).second, best)
            ind = i
            best = peek(pq).second
        end
    end
    return ind
end 
=#

dequeue!(bpq::BatchPriorityQueue) = dequeue!(bpq.pqs[bpq.best_pq_ind])

dequeue_pair!(bpq::BatchPriorityQueue) = dequeue_pair!(bpq.pqs[bpq.best_pq_ind])

peek!(bpq::BatchPriorityQueue) = peek(bpq.pqs[bpq.best_pq_ind])

isempty(bpq::BatchPriorityQueue) = (bpq.best_pq_ind <= 0)

function enqueue!(bpq::BatchPriorityQueue{K, V}, pair::Pair{K, V}) where V where K
    if bpq.best_pq_ind == 0 || lt(bpq.o, pair.second, peek(bpq.pqs[bpq.best_pq_ind]).second)
        bpq.best_pq_ind = mod(pair.first, bpq.num_threads)+1
    end
    enqueue!(bpq.pqs[mod(pair.first, bpq.num_threads)+1], pair)
end