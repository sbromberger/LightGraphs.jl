"""
    PKC(g[, frac = 0.95])

Return the core number for each vertex in graph `g`.

### References
Parallel k-Core Decomposition on Multicore Platforms, Humayun Kabir and Kamesh Madduri, 2017.
https://doi.org/10.1109/IPDPSW.2017.151

### Performance
Time complexity is ``\\mathcal{O}(K_{max}*|V| + |E|)``.
"""
function PKC(g, frac = 0.95)
    deg = Atomic{Int64}.(degree(g))
    buff = [Vector{Int64}(undef, nv(g)) for _ in 1:nthreads()]
    visited = 0
    len_buff = zeros(Int64, nthreads())
    level = 0
    while visited < nv(g)*frac
        process_level(g, deg, buff, level, len_buff)       
        for tid in 1:nthreads()
            visited += len_buff[tid]
            len_buff[tid] = 0
        end
        level += 1
    end
    if visited < nv(g)
        reduce_nvg = nv(g) - visited
        g_small, mapIndexToVtx = subgraph(g, reduce_nvg, level, deg)
        newdeg = Atomic{Int64}.(degree(g_small))
        while visited < nv(g)        
            process_level(g_small, newdeg, buff, level, len_buff)
            for tid in 1:nthreads()
                visited += len_buff[tid]
                len_buff[tid] = 0
            end
            level += 1
        end
        for i in 1:nv(g_small)
            deg[mapIndexToVtx[i]] = newdeg[i]
        end
    end
    return map(x -> x[], deg)
end

function process_level(g, deg, buff, level, len_buff)
    @threads for v in 1:nv(g)
        tid = threadid()
        if deg[v][] == level
            len_buff[tid] += 1
            buff[tid][len_buff[tid]] = v
        end
    end
    @threads for tid in 1:nthreads()
        s = 1
        while s <= len_buff[tid]
            v = buff[tid][s]
            s += 1
            for u in all_neighbors(g, v)
                if deg[u][] > level
                    a = atomic_sub!(deg[u], 1)
                    if a == level+1
                        len_buff[tid] += 1
                        buff[tid][len_buff[tid]] = u
                    end
                    if a <= level
                        atomic_add!(deg[u], 1)
                    end
                end
            end
        end
    end
end

function subgraph(g, nvg_small, level, deg)
    g_small = SmallGraph(nvg_small)
    in_gsmall = falses(nv(g))
    @threads for v in 1:nv(g)
        if deg[v][] >= level
            in_gsmall[v] = true
        end
    end
    vlist = findall(in_gsmall)
    newvid = Vector{Int64}(undef, nv(g))
    vmap = Vector{Int64}(undef, nvg_small)
    for (i, v) in enumerate(vlist)
        newvid[v] = i
        vmap[i] = v
    end
    @threads for s in vlist
        for d in all_neighbors(g, s)
            if in_gsmall[d]
                add_edge!(g_small, newvid[s], newvid[d])
            end
        end
    end
    return g_small, vmap
end

#parallel graph
struct SmallGraph
    adjlist::Vector{Vector{Int64}}
    nvg::Int64
    SmallGraph(nvertices::Int64) = new([Int64[] for _ in 1:nvertices], nvertices)
end
is_directed(::Type{<:SmallGraph}) = false
is_directed(::SmallGraph) = false
nv(g::SmallGraph) = g.nvg
degree(g::SmallGraph) = length.(g.adjlist)
add_edge!(g_small::SmallGraph, u::Int64, v::Int64) = push!(g_small.adjlist[u], v)
neighbors(g::SmallGraph, u::Int64) = g.adjlist[u]
