
# TODO: implement readgexf

"""
savegexf(f::IO, g::SimpleGraph, gname::AbstractString)

Writes a graph `g` with name `gname`
to a file `f` in the
[Gexf](http://gexf.net/format/) format.

Returns 1 (number of graphs written).
"""
function savegexf(f::IO, g::SimpleGraph, gname::AbstractString)
    xdoc = XMLDocument()
    xroot = create_root(xdoc, "gexf")
    set_attribute(xroot,"xmlns","http://www.gexf.net/1.2draft")
    set_attribute(xroot,"version","1.2")
    set_attribute(xroot,"xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
    set_attribute(xroot,"xsi:schemaLocation","http://www.gexf.net/1.2draft/gexf.xsd")

    xmeta = new_child(xroot, "meta")
    xdesc = new_child(xmeta, "description")
    add_text(xdesc, gname)
    xg = new_child(xroot, "graph")
    strdir = is_directed(g) ? "directed" : "undirected"
    set_attribute(xg,"defaultedgetype",strdir)

    xnodes = new_child(xg, "nodes")
    for i=1:nv(g)
        xv = new_child(xnodes, "node")
        set_attribute(xv,"id","$(i-1)")
    end

    xedges = new_child(xg, "edges")
    m=0
    for e in edges(g)
        xe = new_child(xedges, "edge")
        set_attribute(xe,"id","$m")
        set_attribute(xe,"source","$(src(e)-1)")
        set_attribute(xe,"target","$(dst(e)-1)")
        m+=1
    end

    show(f, xdoc)
    return 1
end

filemap[:gexf] = (NI, NI, savegexf, NI)
