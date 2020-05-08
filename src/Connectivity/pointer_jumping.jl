"""
    struct PointerJumping <: WeakConnectivityAlgorithm

A struct representing a [`WeakConnectivityAlgorithm`](@ref)
based on parallel opportunistic pointer jumping

### Optional Fields
`contract_edges` - set to false by default, specifies if edge contraction
should be used by the algorithm

### Performance
Edge contraction can give better performance on very dense graphs but
may also cause load imbalance

### References
Connected-Components algorithms for Mesh-Connected Parallel Computers
Goddard, Kumar and Prins
"""
struct PointerJumping <: WeakConnectivityAlgorithm
    contract_edges::Bool
end

PointerJumping(; contract_edges = false) = PointerJumping(contract_edges)

# pointer jumping without edge contraction
function pj_without_ec(g::SimpleGraph{T}) where T <: Integer
    nthrds = nthreads()
    nvg = nv(g)
    P = collect(vertices(g))    # parent array
    P1 = Vector{T}(undef, nvg)
    @threads for u in vertices(g)
        if degree(g, u) != 0
            P[u] = min(u, first(outneighbors(g, u)))
        end
    end
    partitions = greedy_contiguous_partition(degree(g), nthrds)
    oldP = Vector{T}(undef, nvg)
    flag = true
    while flag
        flag = false
       # opportunistic pointer jumping
       @threads for u_set in partitions
            tid = threadid()
            for u in u_set
                oldP[u] = P[u]
                P1[u] = P[u]
                for v in outneighbors(g, u)
                    P1[u] = min(P1[u], P[v])
                end
            end
        end
        # tree hanging
        @threads for u_set in partitions
            tid = threadid()
            for u in u_set
                P[u] =  P1[u]
                for v in outneighbors(g, u)
                    if oldP[v] == u
                        P[u] = min(P1[u], P1[v])
                    end
                end
            end
        end
        # normal pointer jumping
        @threads for u in vertices(g)
            P[u] = P[P[u]]
        end
        @threads for u in vertices(g)
            if oldP[u] != P[u]
                flag = true
                break
            end
        end
    end
    return components(P)[1]
end

# pointer jumping with edge contraction
function pj_ec(V::Int64, E::Vector{Vector{SimpleEdge{T}}}) where T <: Integer
    nthrds = nthreads()
    E_size = length.(E)
    P = collect(T, 1:V) # parent array
    P1 = Vector{T}(undef, V)
    oldP = Vector{T}(undef, V)
    @threads for _ in 1:nthrds
        tid = threadid()
        for i in 1:E_size[tid]
            e = E[tid][i]
            u, v = src(e), dst(e)
            P[u] = min(P[u], v)
        end
    end
    flag = true
    while flag
        flag = false
        @threads for u in 1:V
            oldP[u] = P[u]
            P1[u] = P[u]
        end
        # opportunistic pointer jumping
        @threads for _ in 1:nthrds
            tid = threadid()
            for i in 1:E_size[tid]
                e = E[tid][i]
                u, v = src(e), dst(e)
                P1[u] = min(P1[u], P[v])
            end
        end
        @threads for u in 1:V
            P[u] = P1[u]
        end
        # tree hanging
        @threads for _ in 1:nthrds
            tid = threadid()
            for i in 1:E_size[tid]
                e = E[tid][i]
                u, v = src(e), dst(e)
                if oldP[v] == u
                    P[u] = min(P1[u], P1[v])
                end
            end
        end
        # normal pointer jumping
        @threads for u in 1:V
            P[u] = P[P[u]]
        end
        E_size .= reduce_edge_set!(E, E_size, P)
        @threads for u in 1:V
            if oldP[u] != P[u]
                flag = true
                break
            end
        end
    end
    return components(P)[1]
end

# contract edges, only those edges remain where P[u] != P[v], where (u,v) ∈ E
# edges array is reused, edges to be removed are moved to the right of the array and new size is returned
function reduce_edge_set!(E::Vector{Vector{SimpleEdge{T}}}, E_size::Vector{Int64}, P::Vector{T}) where T <: Integer
    nthrds = nthreads()
    E_new_size = zeros(Int64, nthrds)
    @threads for _ in 1:nthrds
        tid = threadid()
        cnt = 0
        for i in 1:E_size[tid]
            e = E[tid][i]
            u, v = src(e), dst(e)
            if P[u] != P[v]
                cnt += 1
                # can cause duplicate edges
                E[tid][cnt] = SimpleEdge{T}(P[u], P[v])
            end
        end
        E_new_size[tid] = cnt
    end
    return E_new_size
end

# attempt to partition edges into equal sets to assign to each thread
function build_edge_set(g::SimpleGraph{T}) where T <: Integer
    nthrds = nthreads()
    nvg = nv(g)
    E = [SimpleEdge{T}[] for _ in 1:nthrds]
    partitions = greedy_contiguous_partition(degree(g), nthrds)
    @threads for u_set in partitions
        tid = threadid()
        for u in u_set
            for v in outneighbors(g, u)
                push!(E[tid], SimpleEdge{T}(u, v))
            end
        end
    end
    return E
end

function connected_components(g::SimpleGraph{T}, alg::PointerJumping) where T <: Integer
    if alg.contract_edges
        V = nv(g)
        E = build_edge_set(g)
        return pj_ec(V, E)
    end
    return pj_without_ec(g)
end
