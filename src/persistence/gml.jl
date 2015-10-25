# TODO: implement writegml

"""Returns a dictionary (name=>graph) from file `fn` stored in
[GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language) format.
Can optionally restrict to a single graph by specifying a name in gname."""
function readgml(filename::AbstractString, gname::AbstractString="")
    f = open(readall,filename)
    p = Parsers.GML.parse_dict(f)
    graphs = @compat(Dict{AbstractString, SimpleGraph}())
    for gs in p[:graph]

        dir = @compat(Bool(get(gs, :directed, 0)))
        nodes = [x[:id] for x in gs[:node]]
        mapping = @compat(Dict{Int,Int}())
        for (i,n) in enumerate(nodes)
            mapping[n] = i
        end

        if dir
            g = DiGraph(length(nodes))
            graphname = get(gs, :name, "Unnamed DiGraph")
        else
            g = Graph(length(nodes))
            graphname = get(gs, :name, "Unnamed Graph")
        end
        if (gname == "" || gname == graphname)
            sds = @compat([(Int(x[:source]), Int(x[:target])) for x in gs[:edge]])
            for (s,d) in (sds)
                add_edge!(g, mapping[s], mapping[d])
            end
            (graphs[graphname] = g)
        end
    end
    return graphs
end
