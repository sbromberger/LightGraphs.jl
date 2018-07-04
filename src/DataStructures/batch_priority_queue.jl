import DataStructures: dequeue!, dequeue_pair!, enqueue!, peek, percolate_up!
import Base: isempty

using Base: Ordering, Forward, lt

export BatchPriorityQueue, batch_decrease_key!, peek, dequeue!, dequeue_pair!, 
peek, isempty, queue_decrease_key!

mutable struct BatchPriorityQueue{K,V,O}
    # Binary heap of (element, priority) pairs.
    num_universe::K     #vertices(g)
    num_threads::Integer    #nthreads()
    pqs::Vector{PriorityQueue{K,V,O}}
    buffer_key::Vector{Vector{K}}
    buffer_key_ind::Vector{K}
    best_pq_ind::Integer
    o::Ordering
    max_pq_size::Integer
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
    buffer_key = [Vector{K}(undef, max_size) for _ in 1:num_threads]
    buffer_key_ind = zeros(K, num_threads)

    return BatchPriorityQueue(num_universe, num_threads, pqs, buffer_key, buffer_key_ind, 1, o, max_size)
end

function batch_decrease_key!(
    bpq::BatchPriorityQueue{K, V},
    key_to_val::Vector{V},
    ) where K where V

    for thread_id in 1:(bpq.num_threads)
        @inbounds pq = bpq.pqs[thread_id]
        key_list = bpq.buffer_key[thread_id]
        num_keys = bpq.buffer_key_ind[thread_id]

        @inbounds for k in Iterators.take(key_list, num_keys)
            ind = pq.index[k]
            pq.xs[ind] = Pair{K, V}(k, key_to_val[k])
            percolate_up!(pq, ind) #Cannot use setindex due to throw and push!
        end
        bpq.buffer_key_ind[thread_id] = zero(K)
    end
end

function update_best_ind(bpq::BatchPriorityQueue{K, V}) where K where V
    best_ind = 1
    best_val = (bpq.o == Forward ? typemax(V) : typemin(V))
    for (i, pq) in enumerate(bpq.pqs)
        if !isempty(pq) && lt(bpq.o, peek(pq).second, best_val)
            best_val = peek(pq).second
            best_ind = i
        end
    end
    bpq.best_pq_ind = best_ind
end

dequeue!(bpq::BatchPriorityQueue) = dequeue!(bpq.pqs[bpq.best_pq_ind])

dequeue_pair!(bpq::BatchPriorityQueue) = dequeue_pair!(bpq.pqs[bpq.best_pq_ind])

peek!(bpq::BatchPriorityQueue) = peek(bpq.pqs[bpq.best_pq_ind])

isempty(bpq::BatchPriorityQueue) = isempty(bpq.pqs[bpq.best_pq_ind])

function enqueue!(bpq::BatchPriorityQueue{K, V}, pair::Pair{K, V}) where K where V
    enqueue!(bpq.pqs[mod(pair.first, bpq.num_threads)+1], pair)
end

function queue_decrease_key!(bpq::BatchPriorityQueue{K, V}, Key::K) where K where V 
    ind = mod(Key, bpq.num_threads)+1
    bpq.buffer_key[ind][ (bpq.buffer_key_ind[ind] += 1) ] = Key
end