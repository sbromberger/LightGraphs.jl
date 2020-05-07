struct RandomHook <: WeakConnectivityAlgorithm end

function parallel_cc(V::Vector{Vector{T}}, V_size::Vector{Int64},
                        E::Vector{Vector{SimpleEdge{T}}}, E_size::Vector{Int64},
                            L::Vector{T}, C::BitVector, H::BitVector, N::Vector{T}) where T <: Integer
    sum(E_size) == 0 && return
    nthrds = nthreads()
    @threads for _ in 1:nthrds
        tid = threadid()        
        for i in 1:V_size[tid]
            u = V[tid][i]
            N[u] = zero(T)
        end
    end
    @threads for _ in 1:nthrds
        tid = threadid()
        for i in 1:E_size[tid]
            e = E[tid][i]
            u = src(e); v = dst(e)
            N[u] = v
            N[v] = u
        end
    end
    random_hook!(V, V_size, L, C, H, N)
    parallel_cc(V, reduce_vertex_set!(V, V_size, L), E, reduce_edge_set!(E, E_size, L), L, C, H, N)
    find_roots!(V, V_size, L)
end

function find_roots!(V::Vector{Vector{T}}, V_size::Vector{Int64}, L::Vector{T}) where T <: Integer
    flag = true
    while flag
        flag = false
        @threads for _ in 1:nthreads()
            tid = threadid()
            for i in 1:V_size[tid]
                u = V[tid][i]
                if L[u] != L[L[u]]
                    L[u] = L[L[u]]
                    flag = true
                end
            end
        end
    end
end

function random_hook!(V::Vector{Vector{T}}, V_size::Vector{Int64},
                        L::Vector{T}, C::BitVector, H::BitVector, N::Vector{T}) where T <: Integer
    nthrds = nthreads()
    @threads for _ in 1:nthrds
        tid = threadid()
        for i in 1:V_size[tid]
            u = V[tid][i]
            C[u] = rand() > 0.5
            H[u] = false
        end
    end
    @threads for _ in 1:nthrds
        tid = threadid()        
        for i in 1:V_size[tid]
            u = V[tid][i]
            if N[u] != zero(T)
                v = N[u]
                if C[u] == false && C[v] == true
                    L[u] = v
                    H[u] = true
                    H[v] = true                
                end
            end
        end
    end
    @threads for _ in 1:nthrds
        tid = threadid()        
        for i in 1:V_size[tid]
            u = V[tid][i]
            if N[u] != zero(T)
                if H[u] == true
                    C[u] = true
                else
                    C[u] = !C[u]
                end
            end
        end
    end
    @threads for _ in 1:nthrds
        tid = threadid()        
        for i in 1:V_size[tid]
            u = V[tid][i]
            if N[u] != zero(T)
                v = N[u]
                if C[u] == false && C[v] == true
                    L[u] = L[v]
                end
            end
        end
    end
end

function reduce_vertex_set!(V::Vector{Vector{T}}, V_size::Vector{Int64}, L::Vector{T}) where T <: Integer
    nthrds = nthreads()
    V_new_size = zeros(Int64, nthrds)
    @threads for _ in 1:nthrds
        tid = threadid()
        cnt = 0
        for i in 1:V_size[tid]
            u = V[tid][i]
            if L[u] == u
                cnt += 1
                V[tid][cnt], V[tid][i] = V[tid][i], V[tid][cnt]
            end
        end
        V_new_size[tid] = cnt
    end
    return V_new_size
end

function reduce_edge_set!(E::Vector{Vector{SimpleEdge{T}}}, E_size::Vector{Int64}, L::Vector{T}) where T <: Integer
    nthrds = nthreads()
    E_new_size = zeros(Int64, nthrds)
    @threads for _ in 1:nthrds
        tid = threadid()
        cnt = 0
        for i in 1:E_size[tid]
            e = E[tid][i]
            u = src(e); v = dst(e)
            if L[u] != L[v]
                cnt += 1
                E[tid][cnt] = SimpleEdge{T}(L[u], L[v])
            end
        end
        E_new_size[tid] = cnt
    end
    return E_new_size    
end

function build_vertex_edge_set(g::SimpleGraph{T}) where T <: Integer
    nthrds = nthreads()
    fadjlist = g.fadjlist
    nvg = nv(g)
    V = [T[] for _ in 1:nthrds]
    E = [SimpleEdge{T}[] for _ in 1:nthrds]
    nbrs_start = Vector{Int64}(undef, nvg)
    number_nbrs = zeros(Int64, nvg)
    @threads for u in vertices(g)
        tid = threadid()
        push!(V[tid], u)
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
    return V, E
end

function connected_components(g::SimpleGraph{T}, ::RandomHook; seed = 1) where T <: Integer
    Random.seed!(seed)
    V, E = build_vertex_edge_set(g)
    L = collect(vertices(g))
    N = Vector{T}(undef, nv(g))
    C = falses(nv(g))
    H = falses(nv(g))
    parallel_cc(V, length.(V), E, length.(E), L, C, H, N)
    return components(L)[1]
end
