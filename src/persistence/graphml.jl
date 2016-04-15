# TODO: implement writing a dict of graphs

function _graphml_read_one_graph(e::XMLElement, isdirected::Bool)
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
            warn("Skipping unknown node '$(name(f))'")
        end
    end
    #Put data in graph
    g = (isdirected ? DiGraph : Graph)(length(nodes))
    for edge in edges
        add_edge!(g, edge)
    end
    return g
end

function loadgraphml(io::IO, gname::AbstractString)
    xdoc = parse_string(readall(io))
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "graphml" || error("Not a GraphML file")

    # traverse all its child nodes and print element names
    for c in child_nodes(xroot)  # c is an instance of XMLNode
        if is_elementnode(c)
            e = XMLElement(c)  # this makes an XMLElement instance
            if name(e) == "graph"
                edgedefault = attribute(e, "edgedefault")
                isdir = edgedefault=="directed" ? true :
                             edgedefault=="undirected" ? false : error("Unknown value of edgedefault: $edgedefault")
                if has_attribute(e, "id")
                    graphname = attribute(e, "id")
                else
                    graphname =  isdir ? "digraph" : "graph"
                end
                gname == graphname && return _graphml_read_one_graph(e, isdir)
            else
                warn("Skipping unknown XML element '$(name(e))'")
            end
        end
    end
    error("Graph $gname not found")
end

function loadgraphml_mult(io::IO)
    xdoc = parse_string(readall(io))
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "graphml" || error("Not a GraphML file")

    # traverse all its child nodes and print element names
    graphs = Dict{AbstractString, SimpleGraph}()
    for c in child_nodes(xroot)  # c is an instance of XMLNode
        if is_elementnode(c)
            e = XMLElement(c)  # this makes an XMLElement instance
            if name(e) == "graph"
                edgedefault = attribute(e, "edgedefault")
                isdir = edgedefault=="directed" ? true :
                             edgedefault=="undirected" ? false : error("Unknown value of edgedefault: $edgedefault")
                if has_attribute(e, "id")
                    graphname = attribute(e, "id")
                else
                    graphname =  isdir ? "digraph" : "graph"
                end
                graphs[graphname] =  _graphml_read_one_graph(e, isdir)
            else
                warn("Skipping unknown XML element '$(name(e))'")
            end
        end
    end
    return graphs
end

function savegraphml_mult(io::IO, graphs::Dict)
    xdoc = XMLDocument()
    xroot = create_root(xdoc, "graphml")
    set_attribute(xroot,"xmlns","http://graphml.graphdrawing.org/xmlns")
    set_attribute(xroot,"xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
    set_attribute(xroot,"xsi:schemaLocation","http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd")

    for (gname, g) in graphs
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
    end
    show(io, xdoc)
    return length(graphs)
end

savegraphml(io::IO, g::SimpleGraph, gname::AbstractString) =
    savegraphml_mult(io, Dict(gname=>g))

filemap[:graphml] = (loadgraphml, loadgraphml_mult, savegraphml, savegraphml_mult)
