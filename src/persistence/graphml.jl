# TODO: implement writing a dict of graphs

function _process_graphml(e::XMLElement, isdirected::Bool)
    nodes = Dict{AbstractString,Int}()
    edges = Vector{Edge}()

    nodeid = 1
    for f in child_elements(e)
        if name(f) == "node"
            nodes[attribute(f, "id")] = nodeid
            nodeid += 1
        elseif name(f) == "edge"
            n1 = attribute(f, "source")
            n2 = attribute(f, "target")
            push!(edges, Edge(nodes[n1], nodes[n2]))
        else
            error("Unknown node $(name(f))")
        end
    end
    #Put data in graph
    g = (isdirected ? DiGraph : Graph)(length(nodes))
    for edge in edges
        add_edge!(g, edge)
    end
    return g
end

"""Returns a dictionary (name=>graph) from file `fn` stored in
[GraphML](http://en.wikipedia.org/wiki/GraphML) format.
Can optionally restrict to a single graph by specifying a name in gname.
"""
function readgraphml(filename::AbstractString, gname::AbstractString="")
    xdoc = parse_file(filename)
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "graphml" || error("Not a GraphML file")

    # traverse all its child nodes and print element names
    graphs = Dict{AbstractString, SimpleGraph}()
    for c in child_nodes(xroot)  # c is an instance of XMLNode
        if is_elementnode(c)
            e = XMLElement(c)  # this makes an XMLElement instance
            if name(e) == "graph"
                edgedefault = attribute(e, "edgedefault")
                isdirected = edgedefault=="directed" ? true :
                             edgedefault=="undirected" ? false : error("Unknown value of edgedefault: $edgedefault")
                if has_attribute(e, "id")
                    graphname = attribute(e, "id")
                else
                    if isdirected
                        graphname = "Unnamed DiGraph"
                    else
                        graphname = "Unnamed Graph"
                    end
                end
                if (gname == "" || gname == graphname)
                    g = _process_graphml(e, isdirected)
                    graphs[graphname] =  g
                end
            else
                warn("Skipping unknown XML element $(name(e))")
            end
        end
    end
    return graphs
end

"""
Writes a graph `g` with name `gname`
to a file `f` in the
[GraphML](http://en.wikipedia.org/wiki/GraphML) format.

Returns 1 (number of graphs written).
"""
function writegraphml(f::IO, g::SimpleGraph; gname::AbstractString = "Unnamed Graph")
    xdoc = XMLDocument()
    xroot = create_root(xdoc, "graphml")
    set_attribute(xroot,"xmlns","http://graphml.graphdrawing.org/xmlns")
    set_attribute(xroot,"xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
    set_attribute(xroot,"xsi:schemaLocation","http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd")


    xg = new_child(xroot, "graph")
    set_attribute(xg,"id",gname)
    strdir = is_directed(g) ? "directed" : "undirected"
    set_attribute(xg,"edgedefault",strdir)

    for i=1:nv(g)
        xv = new_child(xg, "node")
        set_attribute(xv,"id","n$(i-1)")
    end

    m = 0
    for e in edges(g)
        xe = new_child(xg, "edge")
        set_attribute(xe,"id","e$m")
        set_attribute(xe,"source","n$(src(e)-1)")
        set_attribute(xe,"target","n$(dst(e)-1)")
        m += 1
    end

    show(f, xdoc)
    return 1
end

writegraphml(g::SimpleGraph; gname::AbstractString = "Unnamed Graph") = writegraphml(STDOUT, g; gname=gname)

function writegraphml(fname::AbstractString, g::SimpleGraph; gname::AbstractString = "Unnamed Graph")
    f = open(fname, "w")
     writegraphml(f, g; gname=gname)
     close(f)
     return 1
 end
