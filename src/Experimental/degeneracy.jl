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
    buff = [Vector{Int64}() for _ in 1:nthreads()]
    e = zeros(Int64, nthreads())
    visited = 0
    level = 0
    while visited < nv(g)*frac
        visited += process_level(g, deg, buff, e, level)
        level += 1
    end
    if visited < nv(g)
        g_small, mapIndexToVtx = subgraph(g, nv(g)-visited, level, deg)
        newdeg = Atomic{Int64}.(degree(g_small))
        while visited < nv(g)
            visited += process_level(g_small, newdeg, buff, e, level)
            level += 1
        end
        for i in 1:nv(g_small)
            deg[mapIndexToVtx[i]] = newdeg[i]
        end
    end
    return map(i -> i[], deg)
end

function process_level(g, deg, buff, e, level)
    e .= 0
    @threads for v in 1:nv(g)
        tid = threadid()
        if deg[v][] == level
            push!(buff[tid], v)
            e[tid] += 1
        end
    end
    @threads for tid in 1:nthreads()
        while !isempty(buff[tid])
            v = popfirst!(buff[tid])
            for u in all_neighbors(g, v)
                if deg[u][] > level
                    a = atomic_sub!(deg[u], 1)
                    if a == level+1
                        push!(buff[tid], u)
                        e[tid] += 1
                    end
                    if a <= level
                        atomic_add!(deg[u], 1)
                    end
                end
            end
        end
    end
    return sum(e)
end

function subgraph(g, nvg_small, level, deg)
    g_small = SmallGraph(nvg_small)
    in_gsmall = falses(nv(g))
    @threads for v in 1:nv(g)
        if deg[v][] >= level
            in_gsmall[v] = true
        end
    end
    vmap = findall(in_gsmall)
    newvid = Vector{Int64}(undef, nv(g))
    for i in 1:length(vmap)
        newvid[vmap[i]] = i
    end
    @threads for s in vmap
        for d in all_neighbors(g, s)
            if in_gsmall[d]
                add_edge!(g_small, newvid[s], newvid[d])
            end
        end
    end
    return g_small, vmap
end

#parallel graph
struct SmallGraph <: AbstractGraph{Int64}
    adjlist::Vector{Vector{Int64}}
    nvg::Int64
    SmallGraph(nvertices::Int64) = new([Int64[] for _ in 1:nvertices], nvertices)
end
is_directed(::Type{<:SmallGraph}) = false
nv(g::SmallGraph) = g.nvg
degree(g::SmallGraph) = length.(g.adjlist)
add_edge!(g_small::SmallGraph, u::Int64, v::Int64) = push!(g_small.adjlist[u], v)
neighbors(g::SmallGraph, u::Int64) = g.adjlist[u]
