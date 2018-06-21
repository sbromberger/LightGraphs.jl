
using Base.Threads

"""
parallel_get_cross_edge!(edge_list, connected_vs, n_threads, local_ind)

Find the smallest index, `best_ind` such that `edge_list[best_ind]` is a cross edge.
Edge `e` is a `e.src` is in a different connected component from `e.dst`.
The connected componenets are represented in `connected_vs` in the format of disjoint set 
data-structures.
Atmost `nthreads` threads will be used.
The indices thread `i` will iterate over depends upon `local_ind[i]`.

### Implementation Notes
Thread 'i' will iterate over indices `local_ind[i]`, `local_ind[i]+n_threads`, `local_ind[i]+2*n_threads`....
Hence, it is required that:
1. {`rem(local_ind[i], n_threads) for i in 1:n_threads`} = {`i-1 for i in 1:n_threads`}.
2. The edges at indices `local_ind[i]-n_threads`, `local_ind[i]-2*n_threads` are not cross edges. 
"""
function parallel_atomic_get_cross_edge!(
    edge_list::Vector{Edge{U}},
    connected_vs::Vector{Atomic{U}},
    n_threads::R,
    local_ind::Vector{R}
    ) where U <: Integer where R <: Integer

    best_ind = Atomic{R}(length(edge_list)+1)

    @threads for id in 1:n_threads
  
        #Each threads checks an edge with step size = n_threads
        ind = local_ind[id]
        while ind < best_ind[]

            u = edge_list[ind].src
            v = edge_list[ind].dst

            #Set connected_vs[u][], connected_vs[v][] to the root of set u, v belong to respectively
            for i in [u, v]  
                root = i
                parent_root = connected_vs[root][]
                while parent_root != root
                    root = parent_root
                    parent_root = connected_vs[root][]
                end

                p_1 = i
                p_2 = connected_vs[i][]
            
                while p_2 != root
                    connected_vs[p_1][] = root
                    p_1 = p_2
                    p_2 = connected_vs[p_1][]
                end
            end

           
            #If edge_list[ind] is a cross edge
            if connected_vs[u][] != connected_vs[v][]
                atomic_min!(best_ind, ind)
                break
            end
            ind += n_threads
        end
        local_ind[id] = ind
    end

    return best_ind[]
end

export parallel_atomic_kruskal_mst


"""
    parallel_atomic_kruskal_mst(g, distmx=weights(g))

Parallel Implementation of Kruskal's minimum spanning tree using atomic operations.
"""
function parallel_atomic_kruskal_mst end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function parallel_atomic_kruskal_mst(g::AG::(!IsDirected),
    distmx::AbstractMatrix{T}=weights(g)) where {T <: Real, U, AG <: AbstractGraph{U}}

    nvg = nv(g)
    neg = ne(g)
    mst = Vector{Edge}()
    sizehint!(mst, nvg - 1)


    weights = Vector{T}()
    sizehint!(weights, neg)

    edge_list = collect(edges(g))
    for e in edge_list
        push!(weights, distmx[src(e), dst(e)])
    end

    edge_list = edge_list[sortperm(weights)]



    connected_vs =  [Atomic{U}(i) for i in one(U):nvg]     
    n_threads = nthreads()
    local_ind = collect(1:n_threads)


    for i in 1:(nvg-1)
        edge_ind = parallel_atomic_get_cross_edge!(edge_list, connected_vs, n_threads, local_ind)

        edge_ind > neg && break
        e = edge_list[edge_ind]
        push!(mst, e)

        # Place the vertices in set e.src into the set e.dst belongs to.
        connected_vs[ connected_vs[e.src][] ][] = connected_vs[e.dst][]
    end

    return mst
end

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################

# Helper function to find the cross edge of minimum weight
function parallel_local_memory_get_cross_edge!(
    edge_list::Vector{Edge{U}},
    connected_vs_t::Vector{Vector{U}},
    n_threads::R,
    local_ind::Vector{R},
    best_ind::R
    ) where U <: Integer where R <: Integer


    @threads for id in 1:n_threads
  
        connected_vs = connected_vs_t[id]
  
        #Each threads checks an edge with step size = n_threads
        ind = local_ind[id]
        while ind < best_ind

            u = edge_list[ind].src
            v = edge_list[ind].dst

            #Set connected_vs[u][], connected_vs[v][] to the root of set u, v belong to respectively
            for i in [u, v]  
                root = i
                while connected_vs[root] != root
                    root = connected_vs[root]
                end

                p_1 = i
                p_2 = connected_vs[i]
            
                while p_2 != root
                    connected_vs[p_1] = root
                    p_1 = p_2
                    p_2 = connected_vs[p_1]
                end
            end
           
            #If edge_list[ind] is a cross edge
            if connected_vs[u] != connected_vs[v]
                break
            end
            ind += n_threads
        end
        local_ind[id] = ind
    end

    return minimum(local_ind)
end


function make_parent!(connected_vs::Vector{U}, i::U) where U <: Integer
    root = i
    while connected_vs[root] != root
        root = connected_vs[root]
    end

    p_1 = i
    p_2 = connected_vs[i]
            
    while p_2 != root
        connected_vs[p_1] = root
        p_1 = p_2
        p_2 = connected_vs[p_1]
    end
end

function union_set!(connected_vs::Vector{U}, x::U, y::U) where U <: Integer
    make_parent!(connected_vs, x)
    make_parent!(connected_vs, y)
    connected_vs[ connected_vs[x] ] = connected_vs[y]
end

export parallel_local_memory_kruskal_mst


"""
    parallel_local_memory_kruskal_mst(g, distmx=weights(g))

Parallel Implementation of Kruskal's minimum spanning tree using a separate union find data-structure
for each thread.
"""
function parallel_local_memory_kruskal_mst end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function parallel_local_memory_kruskal_mst(g::AG::(!IsDirected),
    distmx::AbstractMatrix{T}=weights(g)) where {T <: Real, U, AG <: AbstractGraph{U}}

    nvg = nv(g)
    neg = ne(g)
    mst = Vector{Edge}()
    sizehint!(mst, nvg - 1)


    weights = Vector{T}()
    sizehint!(weights, neg)
    edge_list = collect(edges(g))
    for e in edge_list
        push!(weights, distmx[src(e), dst(e)])
    end
    edge_list = edge_list[sortperm(weights)]
    
    n_threads = nthreads()
    connected_vs_t =  [collect(one(U):nvg) for i in 1:n_threads]
    local_ind = collect(1:n_threads)


    for i in 1:(nvg-1)

        edge_ind = length(edge_list)+1

        for id in 1:n_threads

            ind = local_ind[id]
            (ind <= length(edge_list)) || continue
            connected_vs = connected_vs_t[id]
            u = edge_list[ind].src
            v = edge_list[ind].dst
        
            make_parent!(connected_vs, u)
            make_parent!(connected_vs, v)
            if connected_vs[u] != connected_vs[v]
                edge_ind = min(edge_ind, ind)
            else
                local_ind[id] += n_threads
            end
        end


        if edge_ind > minimum(local_ind)
            edge_ind = parallel_local_memory_get_cross_edge!(edge_list, connected_vs_t, n_threads, local_ind, edge_ind)
        end

        edge_ind > neg && break
        e = edge_list[edge_ind]
        push!(mst, e)

        for id in 1:n_threads
            union_set!(connected_vs_t[id], e.src, e.dst)
        end
    end

    return mst
end
