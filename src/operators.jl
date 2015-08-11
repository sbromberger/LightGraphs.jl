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
    for e in edges(g)
        push!(reve, reverse(e))
    end
    g.edges = reve
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

    for s in iter
        for d in intersect(iter, out_neighbors(g, s))
            newe = Edge(newvid[s], newvid[d])
            if !has_edge(h, newe)
                add_edge!(h, newe)
            end
        end
    end
    return h
end

# dispatch for g[[1,2,3]], g[1:3], g[Set([1,2,3])]
# these are the only allowed dispatches, everything else is slow
getindex(g::SimpleGraph, iter) = induced_subgraph(g, iter)

"""Provides multiplication of a graph `g` by a vector `v` such that spectral
graph functions in [GraphMatrices.jl](https://github.com/jpfairbanks/GraphMatrices.jl) can utilize LightGraphs natively.
"""
function *{T<:Real}(g::Graph, v::Vector{T})
    length(v) == nv(g) || error("Vector size must equal number of vertices")
    y = zeros(T, nv(g))
    for (i,j) in edges(g)
        y[i] += v[j]
        y[j] += v[i]
    end
    return y
end

function *{T<:Real}(g::DiGraph, v::Vector{T})
    length(v) == nv(g) || error("Vector size must equal number of vertices")
    y = zeros(T, nv(g))
    for (i,j) in edges(g)
        y[i] += v[j]
    end
    return y
end
