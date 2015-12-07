# TODO: implement writegml

function _gml_read_one_graph(gs, dir)
    nodes = [x[:id] for x in gs[:node]]
    if dir
        g = DiGraph(length(nodes))
    else
        g = Graph(length(nodes))
    end
    mapping = Dict{Int,Int}()
    for (i,n) in enumerate(nodes)
        mapping[n] = i
    end
    sds = [(Int(x[:source]), Int(x[:target])) for x in gs[:edge]]
    for (s,d) in (sds)
        add_edge!(g, mapping[s], mapping[d])
    end
    return g
end
function loadgml(io::IO, gname::AbstractString)
    p = Parsers.GML.parse_dict(readall(io))
    for gs in p[:graph]
        dir = Bool(get(gs, :directed, 0))
        if dir
            graphname = get(gs, :name, "Unnamed DiGraph")
        else
            graphname = get(gs, :name, "Unnamed Graph")
        end
        (gname == graphname) && return _gml_read_one_graph(gs, dir)
    end
    error("Graph $gname not found")
end

function loadgml_mult(io::IO)
    p = Parsers.GML.parse_dict(readall(io))
    graphs = Dict{AbstractString, SimpleGraph}()
    for gs in p[:graph]
        dir = Bool(get(gs, :directed, 0))
        if dir
            graphname = get(gs, :name, "Unnamed DiGraph")
        else
            graphname = get(gs, :name, "Unnamed Graph")
        end
        graphs[graphname] = _gml_read_one_graph(gs, dir)
    end
    return graphs
end

filemap[:gml] = (loadgml, loadgml_mult, NI, NI)
