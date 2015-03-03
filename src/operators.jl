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

function reverse(g::DiGraph)
    gnv = nv(g)
    gne = ne(g)
    h = DiGraph(gnv)
    for e in edges(g)
        add_edge!(h, rev(e))
    end
    return h
end

function reverse!(g::DiGraph)
    gne = ne(g)
    reve = Set{Edge}()
    for e in edges(g)
        push!(reve, rev(e))
    end
    g.edges = reve
    g.finclist, g.binclist = g.binclist, g.finclist
    return g
end

function union{T<:AbstractGraph}(g::T, h::T)
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

function intersect{T<:AbstractGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(min(gnv, hnv))
    for e in intersect(edges(g),edges(h))
        add_edge!(r,e)
    end
    return r
end

# edges in G but not in H
function difference{T<:AbstractGraph}(g::T, h::T)
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

# only include edges from G or H that do not exist in the other.
function symmetric_difference{T<:AbstractGraph}(g::T, h::T)
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

# merge G and H by union of all vertices and edges.
function compose{T<:AbstractGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    for e in union(edges(g), edges(h))
        add_edge!(r, e)
    end
    return r
end

#@doc "filter g to include only the vertices present in iter which should not have duplicates
#returns the subgraph of g induced by set(iter) along with the mapping from the old vertex names to the new vertex names" ->
function inducedsubgraph(g::AbstractGraph, iter)
    n = length(iter)
    h = typeof(g)(n)
    newvid = Dict{Int,Int}()
    i=1
    for v in iter
        newvid[v] = i
        i +=1
    end
    inducedsubgraph!(h,edges(g),newvid)
    return h, newvid
end

#@doc "inplace filtering for preallocated output, edge iterable, vertex mapping" ->
function inducedsubgraph!(h::AbstractGraph, edges, newvid)
    for edg in edges
        newsrc = get(newvid, src(edg), 0)
        newdst = get(newvid, dst(edg), 0)
        if newsrc > 0 && newdst > 0
            add_edge!(h, newsrc, newdst)
        end
    end
end