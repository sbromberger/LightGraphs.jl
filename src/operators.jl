"""Produces the [graph complement](https://en.wikipedia.org/wiki/Complement_graph)
of a graph."""
function complement(g::Graph)
    gnv = nv(g)
    h = Graph(gnv)
    for i=1:gnv
        for j=i+1:gnv
            if !(has_edge(g,i,j))
                add_edge!(h,i,j)
            end
        end
    end
    return h
end

function complement(g::DiGraph)
    gnv = nv(g)
    h = DiGraph(gnv)
    for i=1:gnv
        for j=1:gnv
            if i != j
                if !(has_edge(g,i,j))
                    add_edge!(h,i,j)
                end
            end
        end
    end
    return h
end

"""(`DiGraph` only) Produces a graph where all edges are reversed from the
original."""
function reverse(g::DiGraph)
    gnv = nv(g)
    gne = ne(g)
    h = DiGraph(gnv)
    for e in edges(g)
        add_edge!(h, reverse(e))
    end
    return h
end

"""(`DiGraph` only) In-place reverse (modifies the original graph)."""
function reverse!(g::DiGraph)
    gne = ne(g)
    reve = Set{Edge}()
    g.fadjlist, g.badjlist = g.badjlist, g.fadjlist
    return g
end

doc"""Produces a graph with $|V(g)| + |V(h)|$ vertices and $|E(g)| + |E(h)|$
edges.

Put simply, the vertices and edges from graph `h` are appended to graph `g`.
"""
function blkdiag{T<:SimpleGraph}(g::T, h::T)
    gnv = nv(g)
    r = T(gnv + nv(h))
    for e in edges(g)
        add_edge!(r,e)
    end
    for e in edges(h)
        add_edge!(r, gnv+src(e), gnv+dst(e))
    end
    return r
end

"""Produces a graph with edges that are only in both graph `g` and graph `h`.

Note that this function may produce a graph with 0-degree vertices.
"""
function intersect{T<:SimpleGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(min(gnv, hnv))
    for e in intersect(edges(g),edges(h))
        add_edge!(r,e)
    end
    return r
end

"""Produces a graph with edges in graph `g` that are not in graph `h`.

Note that this function may produce a graph with 0-degree vertices.
"""
function difference{T<:SimpleGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(gnv)
    for e in edges(g)
        if !has_edge(h, e)
            add_edge!(r,e)
        end
    end
    return r
end

"""Produces a graph with edges from graph `g` that do not exist in graph `h`,
and vice versa.

Note that this function may produce a graph with 0-degree vertices.
"""
function symmetric_difference{T<:SimpleGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    for e in edges(g)
        if !has_edge(h, e)
            add_edge!(r, e)
        end
    end
    for e in edges(h)
        if !has_edge(g, e) && !has_edge(r, e)
            add_edge!(r, e)
        end
    end
    return r
end

"""Merges graphs `g` and `h` by taking the set union of all vertices and edges.
"""
function union{T<:SimpleGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    for e in union(edges(g), edges(h))
        add_edge!(r, e)
    end
    return r
end


"""Merges graphs `g` and `h` using `blkdiag` and then adds all the edges between
 the vertices in `g` and those in `h`.
"""
function join(g::Graph, h::Graph)
    r = blkdiag(g, h)
    for i=1:nv(g)
        for j=nv(g)+1:nv(g)+nv(h)
            add_edge!(r, i, j)
        end
    end
    return r
end

"""Filters graph `g` to include only the vertices present in the iterable
argument `vs`. Returns the subgraph of `g` induced by `vs`.
"""
function induced_subgraph{T<:SimpleGraph}(g::T, iter)
    n = length(iter)
    isequal(n, length(unique(iter))) || error("Vertices in subgraph list must be unique")
    isequal(n, nv(g)) && return copy(g) # if iter is not a proper subgraph

    h = T(n)
    newvid = Dict{Int, Int}()
    i=1
    for (i,v) in enumerate(iter)
        newvid[v] = i
    end

    iterset = Set(iter)
    for s in iter
        for d in out_neighbors(g, s)
            # println("s = $s, d = $d")
            if d in iterset && has_edge(g, s, d)
                newe = Edge(newvid[s], newvid[d])
                if !has_edge(h, newe)
                    add_edge!(h, newe)
                end
            end
        end
    end
    return h
end

# dispatch for g[[1,2,3]], g[1:3], g[Set([1,2,3])]
# these are the only allowed dispatches, everything else is slow
getindex(g::SimpleGraph, iter) = induced_subgraph(g, iter)


# The following operators allow one to use a LightGraphs.Graph as a matrix in eigensolvers for spectral ranking and partitioning.
# """Provides multiplication of a graph `g` by a vector `v` such that spectral
# graph functions in [GraphMatrices.jl](https://github.com/jpfairbanks/GraphMatrices.jl) can utilize LightGraphs natively.
# """
function *{T<:Real}(g::Graph, v::Vector{T})
    length(v) == nv(g) || error("Vector size must equal number of vertices")
    y = zeros(T, nv(g))
    for e in edges(g)
        i = src(e)
        j = dst(e)
        y[i] += v[j]
        y[j] += v[i]
    end
    return y
end

function *{T<:Real}(g::DiGraph, v::Vector{T})
    length(v) == nv(g) || error("Vector size must equal number of vertices")
    y = zeros(T, nv(g))
    for e in edges(g)
        i = src(e)
        j = dst(e)
        y[i] += v[j]
    end
    return y
end

"""sum(g,i) provides 1:indegree or 2:outdegree vectors"""
function sum(g::SimpleGraph, dim::Int)
    dim == 1 && return indegree(g, vertices(g))
    dim == 2 && return outdegree(g, vertices(g))
    error("Graphs are only two dimensional")
end


size(g::SimpleGraph) = (nv(g), nv(g))
"""size(g,i) provides 1:nv or 2:nv else 1 """
size(g::Graph,dim::Int) = (dim == 1 || dim == 2)? nv(g) : 1

"""sum(g) provides the number of edges in the graph"""
sum(g::SimpleGraph) = ne(g)

"""sparse(g) is the adjacency_matrix of g"""
sparse(g::SimpleGraph) = adjacency_matrix(g)

#arrayfunctions = (:eltype, :length, :ndims, :size, :strides, :issym)
eltype(g::SimpleGraph) = Float64
length(g::SimpleGraph) = nv(g)*nv(g)
ndims(g::SimpleGraph) = 2
issym(g::SimpleGraph) = !is_directed(g)
