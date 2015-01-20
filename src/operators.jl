function complement(g::FastGraph)
    gnv = nv(g)
    h = FastGraph(gnv)
    for i=1:gnv
        for j=i+1:gnv
            if !(has_edge(g,i,j))
                add_edge!(h,i,j)
            end
        end
    end
    return h
end

function complement(g::FastDiGraph)
    gnv = nv(g)
    h = FastDiGraph(gnv)
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

function reverse(g::FastDiGraph)
    gnv = nv(g)
    gne = ne(g)
    h = FastDiGraph(gnv)
    for e in edges(g)
        add_edge!(h, rev(e))
    end
    return h
end

function reverse!(g::FastDiGraph)
    gne = ne(g)
    reve = Set{Edge}()
    for e in edges(g)
        push!(reve, rev(e))
    end
    g.edges = reve
    g.finclist, g.binclist = g.binclist, g.finclist
    return g
end

function union{T<:AbstractFastGraph}(g::T, h::T)
    gnv = nv(g)
    r = T(gnv + nv(h))
    for e in edges(g)
        add_edge!(r,e)
    end
    for e in edges(h)
        add_edge!(r, gnv+src(e), gnv+dst(e), dist(e))
    end
    return r
end

function intersect{T<:AbstractFastGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(min(gnv, hnv))
    for e in intersect(edges(g),edges(h))
        add_edge!(r,e)
    end
    return r
end

function difference{T<:AbstractFastGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(gnv)
    for e in edges(g)
        if !(e in edges(h))
            add_edge!(r,e)
        end
    end
    return r
end

function symmetric_difference{T<:AbstractFastGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    for e in edges(g)
        if !(e in edges(h))
            add_edge!(r, e)
        end
    end
    for e in edges(h)
        if !(e in edges(g)) && !(e in edges(r))
            add_edge!(r, e)
        end
    end
    return r
end

function compose{T<:AbstractFastGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    for e in union(edges(g), edges(h))
        add_edge!(r, e)
    end
    return r
end
