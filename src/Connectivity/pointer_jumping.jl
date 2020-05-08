struct PointerJumping <: WeakConnectivityAlgorithm end

function parallel_cc(V::Int64, E::Vector{Vector{SimpleEdge{T}}}) where T <: Integer
    nthrds = nthreads()
    E_size = length.(E)
    P = collect(T, 1:V)
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
    while sum(E_size) > 0
    	@threads for u in 1:V
		    oldP[u] = P[u]
            P1[u] = P[u]
    	end
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
	    @threads for u in 1:V
            P[u] = P[P[u]]
    	end
    	E_size .= reduce_edge_set!(E, E_size, P)
    end
    return P
end

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
                E[tid][cnt] = SimpleEdge{T}(P[u], P[v])
            end
        end
        E_new_size[tid] = cnt
    end
    return E_new_size
end

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

function connected_components(g::SimpleGraph{T}, ::PointerJumping) where T <: Integer
    V = nv(g)
    E = build_edge_set(g)
    return components(parallel_cc(V, E))[1]
end
