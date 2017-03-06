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
function loadgml(io::IO, gname::String)
    p = GML.parse_dict(readall(io))
    for gs in p[:graph]
        dir = Bool(get(gs, :directed, 0))
        graphname = get(gs, :label, dir ? "digraph" : "graph")

        (gname == graphname) && return _gml_read_one_graph(gs, dir)
    end
    error("Graph $gname not found")
end

function loadgml_mult(io::IO)
    p = GML.parse_dict(readall(io))
    graphs = Dict{String, AbstractGraph}()
    for gs in p[:graph]
        dir = Bool(get(gs, :directed, 0))
        graphname = get(gs, :label, dir ? "digraph" : "graph")
        graphs[graphname] = _gml_read_one_graph(gs, dir)
    end
    return graphs
end

"""
savegml(f, g, gname = "graph")

Writes a graph `g` with name `gname`
to a file `f` in the
[GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language) format.
"""
function savegml(io::IO, g::AbstractGraph, gname::String = "")
    println(io, "graph")
    println(io, "[")
    length(gname) > 0 && println(io, "label \"$gname\"")
    is_directed(g) && println(io, "directed 1")
    for i=1:nv(g)
        println(io,"\tnode")
        println(io,"\t[")
        println(io,"\t\tid $i")
        println(io,"\t]")
    end
    for e in edges(g)
        s, t = Tuple(e)
        println(io,"\tedge")
        println(io,"\t[")
        println(io,"\t\tsource $s")
        println(io,"\t\ttarget $t")
        println(io,"\t]")
    end
    println(io, "]")
    return 1
end


"""Writes a dictionary of (name=>graph) to a file `fn`

Returns number of graphs written.
"""
function savegml_mult(io::IO, graphs::Dict)
    ng = 0
    for (gname, g) in graphs
        ng += savegml(io, g, gname)
    end
    return ng
end

filemap[:gml] = (loadgml, loadgml_mult, savegml, savegml_mult)
