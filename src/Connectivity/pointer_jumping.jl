struct PointerJumping <: WeakConnectivityAlgorithm end

function parallel_cc(V::Int64, E::Vector{Vector{SimpleEdge{T}}},
                        E_size::Vector{Int64}, L::Vector{T}) where T <: Integer
    sum(E_size) == 0 && return
    nthrds = nthreads()
    l2h = zeros(Int64, nthrds)
    h2l = zeros(Int64, nthrds)
    @threads for _ in 1:nthrds
        tid = threadid()
        for i in 1:E_size[tid]
            e = E[tid][i]
            u, v = src(e), dst(e)
            if u < v
                l2h[tid] += 1
            else
                h2l[tid] += 1
            end
        end
    end
    n1 = sum(l2h)
    n2 = sum(h2l)
    @threads for _ in 1:nthrds
        tid = threadid()
        for i in 1:E_size[tid]
            e = E[tid][i]
            u, v = src(e), dst(e)
            if (n1 >= n2 && u < v)
                L[u] = v
            elseif (n1 < n2 && u > v)
                L[v] = u
            end
        end
    end
    E_new_size = reduce_edge_set!(E, E_size, L)
    parallel_cc(V, E, E_new_size, L)
    find_roots!(V, L)
end

function find_roots!(V::Int64, L::Vector{T}) where T <: Integer
    flag = true
    while flag
        flag = false
        @threads for u in 1:V
            if L[u] != L[L[u]]
                L[u] = L[L[u]]
                flag = true
            end
        end
    end
end

function reduce_edge_set!(E::Vector{Vector{SimpleEdge{T}}}, E_size::Vector{Int64}, L::Vector{T}) where T <: Integer
    nthrds = nthreads()
    E_new_size = zeros(Int64, nthrds)
    @threads for _ in 1:nthrds
        tid = threadid()
        cnt = 0
        for i in 1:E_size[tid]
            e = E[tid][i]
            u, v = src(e), dst(e)
            if L[u] != L[v]
                cnt += 1
                E[tid][cnt] = SimpleEdge{T}(L[u], L[v])
            end
        end
        E_new_size[tid] = cnt
    end
    return E_new_size
end

function build_edge_set(g::SimpleGraph{T}) where T <: Integer
    nthrds = nthreads()
    fadjlist = g.fadjlist
    nvg = nv(g)
    E = [SimpleEdge{T}[] for _ in 1:nthrds]
    nbrs_start = Vector{T}(undef, nvg)
    number_nbrs = zeros(T, nvg)
    @threads for u in vertices(g)
        list_u = fadjlist[u]
        nbrs_start[u] = searchsortedfirst(list_u, u)
        number_nbrs[u] = length(list_u)-nbrs_start[u]+1
    end
    partitions = optimal_contiguous_partition(number_nbrs, nthrds)
    @threads for u_set in partitions
        tid = threadid()
        for u in u_set
            list_u = fadjlist[u]
            for i in nbrs_start[u]:length(list_u)
                v = list_u[i]
                push!(E[tid], SimpleEdge{T}(u, v))
            end
        end
    end
    return E
end

function connected_components(g::SimpleGraph{T}, ::PointerJumping) where T <: Integer
    V = nv(g)
    E = build_edge_set(g)
    E_size = length.(E)
    L = collect(vertices(g))
    parallel_cc(V, E, E_size, L)
    return components(L)[1]
end
