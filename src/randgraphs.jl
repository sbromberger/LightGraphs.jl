# These are test functions only, used for consistent centrality comparisons.

function SimpleGraph(nv::Integer, ne::Integer)
    g = SimpleGraph(nv)

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

function SimpleDiGraph(nv::Integer, ne::Integer)
    g = SimpleDiGraph(nv)

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
