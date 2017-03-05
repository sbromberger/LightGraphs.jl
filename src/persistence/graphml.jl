# TODO: implement writing a dict of graphs

function _graphml_read_one_graph(el::EzXML.Node, isdirected::Bool)
    nodes = Dict{String,Int}()
    edges = Vector{Edge}()

    nodeid = 1
    for f in eachelement(el)
        if name(f) == "node"
            nodes[f["id"]] = nodeid
            nodeid += 1
        elseif name(f) == "edge"
            n1 = f["source"]
            n2 = f["target"]
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

function loadgraphml(io::IO, gname::String)
    xdoc = parsexml(readall(io))
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "graphml" || error("Not a GraphML file")

    # traverse all its child nodes and print element names
    for el in eachelement(xroot)
        if name(el) == "graph"
            edgedefault = el["edgedefault"]
            isdir = edgedefault == "directed"   ? true  :
                    edgedefault == "undirected" ? false :
                    error("Unknown value of edgedefault: $edgedefault")
            if haskey(el, "id")
                graphname = el["id"]
            else
                graphname = isdir ? "digraph" : "graph"
            end
            gname == graphname && return _graphml_read_one_graph(el, isdir)
        else
            warn("Skipping unknown XML element '$(name(el))'")
        end
    end
    error("Graph $gname not found")
end

function loadgraphml_mult(io::IO)
    xdoc = parsexml(readall(io))
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "graphml" || error("Not a GraphML file")

    # traverse all its child nodes and print element names
    graphs = Dict{String, AbstractGraph}()
    for el in eachelement(xroot)
        if name(el) == "graph"
            edgedefault = el["edgedefault"]
            isdir = edgedefault == "directed"   ? true  :
                    edgedefault == "undirected" ? false :
                    error("Unknown value of edgedefault: $edgedefault")
            if haskey(el, "id")
                graphname = el["id"]
            else
                graphname = isdir ? "digraph" : "graph"
            end
            graphs[graphname] = _graphml_read_one_graph(el, isdir)
        else
            warn("Skipping unknown XML element '$(name(el))'")
        end
    end
    return graphs
end

function savegraphml_mult(io::IO, graphs::Dict)
    xdoc = XMLDocument()
    xroot = setroot!(xdoc, ElementNode("graphml"))
    xroot["xmlns"] = "http://graphml.graphdrawing.org/xmlns"
    xroot["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
    xroot["xsi:schemaLocation"] = "http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd"

    for (gname, g) in graphs
        xg = addelement!(xroot, "graph")
        xg["id"] = gname
        xg["edgedefault"] = is_directed(g) ? "directed" : "undirected"

        for i in 1:nv(g)
            xv = addelement!(xg, "node")
            xv["id"] = "n$(i-1)"
        end

        m = 0
        for e in edges(g)
            xe = addelement!(xg, "edge")
            xe["id"] = "e$m"
            xe["source"] = "n$(src(e)-1)"
            xe["target"] = "n$(dst(e)-1)"
            m += 1
        end
    end
    prettyprint(io, xdoc)
    return length(graphs)
end

savegraphml(io::IO, g::AbstractGraph, gname::String) =
    savegraphml_mult(io, Dict(gname=>g))

filemap[:graphml] = (loadgraphml, loadgraphml_mult, savegraphml, savegraphml_mult)
