"""
    struct KabirMadduri <: CoreAlgorithm

A [`CoreAlgorithm`] specifying the multithreaded Kabir-Maduri decomposition algorithm.

### Optional Arguments
- `frac::Float64`:  the fraction of vertices past which a subgraph with high-coreness values
is created using the current core estimates (default: `0.95`)

### References
- Parallel k-Core Decomposition on Multicore Platforms, Humayun Kabir and Kamesh Madduri, 2017.
https://doi.org/10.1109/IPDPSW.2017.151
"""
struct KabirMadduri <: CoreAlgorithm
    frac::Float64
end

KabirMadduri(;frac=0.95) = KabirMadduri(frac)

function core_number(g::AbstractGraph{T}, alg::KabirMadduri) where {T}
    has_self_loops(g) && throw(ArgumentError("graph must not have self-loops"))
    deg = Atomic{T}.(degree(g))
    buf = [Vector{T}() for _ in 1:nthreads()]
    buf_end = zeros(Int64, nthreads())
    visited = 0
    level = 0
    while visited < nv(g)*alg.frac
        visited += _process_level!(g, deg, level, buf, buf_end)
        level += 1
    end
    if visited < nv(g)
        g_small, vmap, newdeg = subgraph(g, deg, level, nv(g)-visited)
        while visited < nv(g)
            visited += _process_level!(g_small, newdeg, level, buf, buf_end)
            level += 1
        end
        @threads for i in 1:nv(g_small)
            deg[vmap[i]][] = newdeg[i][]
        end
    end
    core_num = Vector{T}(undef, nv(g))
    @threads for v in 1:nv(g)
        core_num[v] = deg[v][]
    end
    return core_num
end

function _process_level!(g::AbstractGraph{T}, deg::Vector{Atomic{T}}, level::Int64,
                       buf::Vector{Vector{T}}, buf_end::Vector{Int64}) where T
    buf_end .= 0
    @threads for v in 1:nv(g)
        if deg[v][] == level
            tid = threadid()
            push!(buf[tid], v)
            buf_end[tid] += 1
        end
    end
    @threads for tid in 1:nthreads()
        while !isempty(buf[tid])
            v = popfirst!(buf[tid])
            for u in all_neighbors(g, v)
                if deg[u][] > level
                    a = atomic_sub!(deg[u], one(T))
                    if a == level+1
                        push!(buf[tid], u)
                        buf_end[tid] += 1
                    end
                    if a <= level
                        atomic_add!(deg[u], one(T))
                    end
                end
            end
        end
    end
    return sum(buf_end)
end

# Create a new graph with the the remaining vertices = (1-frac)*nv(g)
# Add edge u => v if u => v is an edge in the original graph and both u and v have coreness values larger than level
# This improves the process phase because number of adjacencies are lower in this graph
# Also increases locality in memory access pattern because of the smaller size
function subgraph(g::AbstractGraph{T}, deg::Vector{Atomic{T}}, level::Int64, nvg_small::Int64) where T
    g_small = SimpleGraph{T}(nvg_small)
    in_gsmall = falses(nv(g))
    @threads for v in 1:nv(g)
        if deg[v][] >= level
            in_gsmall[v] = true
        end
    end
    vmap = findall(in_gsmall)
    newvid = Vector{Int64}(undef, nv(g))
    newdeg = Vector{Atomic{T}}(undef, nvg_small)
    @threads for i in 1:nvg_small
        newvid[vmap[i]] = i
        newdeg[i] = Atomic{T}(deg[vmap[i]][])
    end
    @threads for s in vmap
        for d in all_neighbors(g, s)
            if in_gsmall[d]
                push!(g_small.fadjlist[newvid[s]], newvid[d])
            end
        end
    end
    return g_small, vmap, newdeg
end
