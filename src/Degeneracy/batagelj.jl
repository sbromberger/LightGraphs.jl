function core_number(g::AbstractGraph{T}, ::Batagelj) where {T}
    has_self_loops(g) && throw(ArgumentError("graph must not have self-loops"))
    n = nv(g)
    deg = T.(degree(g)) # this will contain core number for each vertex of graph
    maxdeg = maximum(deg) # maximum degree of a vertex in graph
    bin = zeros(T, maxdeg+1) # used for bin-sort and storing starting positions of bins
    vert = zeros(T, n) # contains the set of vertices, sorted by their degrees
    pos = zeros(T, n) # contains positions of vertices in array vert

    # count number of vertices will be in each bin
    for v = 1:n
        bin[deg[v]+1] += one(T)
    end
    # from bin sizes determine starting positions of bins in array vert
    start = one(T)
    for d = zero(T):maxdeg
        num = bin[d+1]
        bin[d+1] = start
        start += num
    end
    # sort the vertices in increasing order of their degrees and store in array vert
    for v in vertices(g)
        pos[v] = bin[deg[v]+1]
        vert[pos[v]] = v
        bin[deg[v]+1] += one(T)
    end

    # recover starting positions of the bins
    for d = maxdeg:-1:one(T)
       bin[d+1] = bin[d]
    end
    bin[1] = one(T)

    # cores decomposition
    for i = 1:n
        v = vert[i]
        # for each neighbor u of vertex v with higher degree we have to decrease its degree and move it for one bin to the left
        for u in all_neighbors(g, v)
            if deg[u] > deg[v]
                du = deg[u]
                pu = pos[u]
                pw = bin[du+1]
                w = vert[pw]
                if u != w
                    pos[u] = pw
                    vert[pu] = w
                    pos[w] = pu
                    vert[pw] = u
                end
                bin[du+1] += one(T)
                deg[u] -= one(T)
            end
        end
    end
    return deg
end
