# Code in this file inspired by NetworkX.

"""
    core_number(g)

Return the core number for each vertex in graph `g`.

A k-core is a maximal subgraph that contains vertices of degree `k` or more.
The core number of a vertex is the largest value `k` of a k-core containing
that vertex.

### Implementation Notes
Not implemented for graphs with self loops.

### References
* An O(m) Algorithm for Cores Decomposition of Networks,
    Vladimir Batagelj and Matjaz Zaversnik, 2003.
    http://arxiv.org/abs/cs.DS/0310049
"""
function core_number(g::AbstractGraph{T}) where T
    has_self_loops(g) && throw(ArgumentError("graph must not have self-loops"))
    degrees = degree(g)
    vs = sortperm(degrees)
    bin_boundaries = [1]
    curr_degree = 0
    for (i, v) in enumerate(vs)
        if degrees[v] > curr_degree
            append!(bin_boundaries, repmat([i], (degrees[v] - curr_degree)))
            curr_degree = degrees[v]
        end
    end
    vertex_pos = sortperm(vs)
    # initial guesses for core is degree
    core = degrees
    nbrs = [Set(allneighbors(g, v)) for v in vertices(g)]
    for v in vs
        for u in nbrs[v]
            if core[u] > core[v]
                pop!(nbrs[u], v)
                pos = vertex_pos[u]
                bin_start = bin_boundaries[core[u] + 1]
                vertex_pos[u] = bin_start
                vertex_pos[vs[bin_start]] = pos
                vs[bin_start], vs[pos] = vs[pos], vs[bin_start]
                bin_boundaries[core[u] + 1] += 1
                core[u] -= 1
            end
        end
    end
    return core
end

"""
    k_core(g[, k]; corenum=core_number(g))

Return a vector of vertices in the k-core of graph `g`.
If `k` is not specified, return the core with the largest degree.

A k-core is a maximal subgraph that contains vertices of degree `k` or more.

### Implementation Notes
Not implemented for graphs with self loops.

### References
- An O(m) Algorithm for Cores Decomposition of Networks,
    Vladimir Batagelj and Matjaz Zaversnik, 2003.
    http://arxiv.org/abs/cs.DS/0310049
"""
function k_core(g::AbstractGraph, k=-1; corenum=core_number(g))
    if (k == -1)
        k = maximum(corenum) # max core
    end

    return find(x -> x >= k, corenum)
end

"""
    k_shell(g[, k]; corenum=core_number(g))

Return a vector of vertices in the k-shell of `g`.
If `k` is not specified, return the shell of the core
with the largest degree.

The k-shell is the subgraph of vertices in the `k`-core but not in
the (`k+1`)-core. This is similar to `k_corona` but in that case
only neighbors in the k-core are considered.


### Implementation Notes
Not implemented for graphs with parallel edges or self loops.

### References
- A model of Internet topology using k-shell decomposition
   Shai Carmi, Shlomo Havlin, Scott Kirkpatrick, Yuval Shavitt,
   and Eran Shir, PNAS  July 3, 2007   vol. 104  no. 27  11150-11154
   http://www.pnas.org/content/104/27/11150.full
"""
function k_shell(g::AbstractGraph, k=-1; corenum=core_number(g))
    if k == -1
        k = maximum(corenum)
    end
    return find(x -> x == k, corenum)
end

"""
    k_crust(g[, k]; corenum=core_number(g))

Return a vector of vertices in the k-crust of `g`. 
If `k` is not specified, return the crust of the core with
the largest degree.

The k-crust is the graph `g` with the k-core removed.

### Implementation Notes
This definition of k-crust is different than the definition in References.
The k-crust in References is equivalent to the `k+1` crust of this algorithm.

Not implemented for graphs with self loops.

### References
- A model of Internet topology using k-shell decomposition
   Shai Carmi, Shlomo Havlin, Scott Kirkpatrick, Yuval Shavitt,
   and Eran Shir, PNAS  July 3, 2007   vol. 104  no. 27  11150-11154
   http://www.pnas.org/content/104/27/11150.full
"""
function k_crust(g, k=-1; corenum=core_number(g))
    if k == -1
        k = maximum(corenum) - 1
    end
    return find(x -> x <= k, corenum)
end

"""
    k_corona(g, k; corenum=core_number(g))

Return a vector of vertices in the k-corona of `g`. 

The k-corona is the subgraph of vertices in the k-core which
have exactly `k` neighbors in the k-core.

### Implementation Notes
Not implemented for graphs with parallel edges or self loops.

### References

- k-core (bootstrap) percolation on complex networks:
   Critical phenomena and nonlocal effects,
   A. V. Goltsev, S. N. Dorogovtsev, and J. F. F. Mendes,
   Phys. Rev. E 73, 056101 (2006)
   http://link.aps.org/doi/10.1103/PhysRevE.73.056101
"""
function k_corona(g::AbstractGraph, k; corenum=core_number(g))
    kcore = k_core(g, k)
    kcoreg = g[kcore]
    kcoredeg = degree(kcoreg)

    return kcore[findin(kcoredeg, k)]
end
