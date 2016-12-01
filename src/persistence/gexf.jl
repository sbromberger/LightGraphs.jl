
# TODO: implement readgexf

"""
savegexf(f::IO, g::SimpleGraph, gname::String)

Writes a graph `g` with name `gname`
to a file `f` in the
[Gexf](http://gexf.net/format/) format.

Returns 1 (number of graphs written).
"""
function savegexf(f::IO, g::SimpleGraph, gname::String)
    xdoc = XMLDocument()
    xroot = setroot!(xdoc, ElementNode("gexf"))
    xroot["xmlns"] = "http://www.gexf.net/1.2draft"
    xroot["version"] = "1.2"
    xroot["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
    xroot["xsi:schemaLocation"] = "http://www.gexf.net/1.2draft/gexf.xsd"

    xmeta = addelement!(xroot, "meta")
    addelement!(xmeta, "description", gname)
    xg = addelement!(xroot, "graph")
    strdir = is_directed(g) ? "directed" : "undirected"
    xg["defaultedgetype"] = strdir

    xnodes = addelement!(xg, "nodes")
    for i in 1:nv(g)
        xv = addelement!(xnodes, "node")
        xv["id"] = "$(i-1)"
    end

    xedges = addelement!(xg, "edges")
    m = 0
    for e in edges(g)
        xe = addelement!(xedges, "edge")
        xe["id"] = "$m"
        xe["source"] = "$(src(e)-1)"
        xe["target"] = "$(dst(e)-1)"
        m += 1
    end

    prettyprint(f, xdoc)
    return 1
end

filemap[:gexf] = (NI, NI, savegexf, NI)
