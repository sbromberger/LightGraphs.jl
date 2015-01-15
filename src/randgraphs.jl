# These are test functions only, used for consistent centrality comparisons.

function FastGraph(nv::Integer, ne::Integer)
    g = FastGraph(nv)

    i = 1
    while i <= ne
        source = rand(1:nv)
        dest = rand(1:nv)
        e = (source, dest)
        if (source != dest) && !(has_edge(g,source,dest))
            i+= 1
            add_edge!(g,source,dest)
        end
    end
    return g
end

function FastDiGraph(nv::Integer, ne::Integer)
    g = FastDiGraph(nv)

    i = 1
    while i <= ne
        source = rand(1:nv)
        dest = rand(1:nv)
        e = (source, dest)
        if (source != dest) && !(has_edge(g,source,dest))
            i+= 1
            add_edge!(g,source,dest)
        end
    end
    return g
end
