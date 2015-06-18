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
        add_edge!(h, reverse(e))
    end
    return h
end

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

function blkdiag{T<:AbstractGraph}(g::T, h::T)
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
function union{T<:AbstractGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    for e in union(edges(g), edges(h))
        add_edge!(r, e)
    end
    return r
end

#@doc "filter g to include only the vertices present in iter which should not have duplicates
#returns the subgraph of g. Mappings are in iter. ->
function inducedsubgraph{T<:AbstractGraph}(g::T, iter)
    if unique(iter) != iter
        error("vertices in subgraph must be unique")
    else
        n = length(iter)
        h = T(n)
        newvid = Dict{Int, Int}()

        for (i, v) in enumerate(iter)
            newvid[v] = i
        end
        for s in iter
            for d in intersect(iter, out_neighbors(g, s))
                newe = Edge(newvid[s], newvid[d])
                if !has_edge(h, newe)
                    add_edge!(h,newvid[s], newvid[d])
                end
            end
        end
        return h
    end
end
