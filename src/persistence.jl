# The format of simplegraph files is as follows:
# a one line header: <num_vertices>, <num_edges>, {"d" | "u"}, <name>
#   - num_vertices is an integer
#   - num_edges is an integer
#   - "d" for directed graph, "u" for undirected. Note that this
#       option does not perform any additional edge construction; it's
#       merely used to return the correct type of graph.
#   - name is a string
# header followed by a list of (comma-delimited) edges - src,dst.
# Multiple graphs may be present in one file.


function _read_one_graph(f::IO, n_v::Integer, n_e::Integer, directed::Bool)
    readedges = Set{@compat Tuple{Int,Int}}()
    if directed
        g = DiGraph(n_v)
    else
        g = Graph(n_v)
    end
    for i = 1:n_e
        line = chomp(readline(f))
        if length(line) > 0
            src_s, dst_s = @compat(split(line,r"\s*,\s*"))
            src = parse(Int, src_s)
            dst = parse(Int, dst_s)
            add_edge!(g, src, dst)
        end
    end
    return g
end

function _skip_one_graph(f::IO, n_e::Integer)
    for _ in 1:n_e
        readline(f)
    end
end

"""Returns a dictionary of (name=>graph) loaded from file `fn`."""
function readgraph(fn::AbstractString, gname::AbstractString="")
    graphs = @compat(Dict{AbstractString, SimpleGraph}())
    f = GZip.open(fn,"r")        # should work even if uncompressed

    while !eof(f)
        line = strip(chomp(readline(f)))
        if startswith(line,"#") || line == ""
            next
        else
            nvstr, nestr, dirundir, graphname = @compat(split(line, r"s*,s*", limit=4))
            n_v = parse(Int, nvstr)
            n_e = parse(Int, nestr)
            dirundir = strip(dirundir)
            graphname = strip(graphname)
            directed = !(dirundir == "u")
            if (gname == "" || gname == graphname)
                g = _read_one_graph(f, n_v, n_e, directed)
                graphs[graphname] = g
            else
                _skip_one_graph(f, n_e)
            end
        end
    end
    return graphs
end

"""Writes a graph `g` with name `graphname` in a proprietary format
to the IO stream designated by `io`.

Returns 1 (number of graphs written).
"""
function write(io::IO, graphname::AbstractString, g::SimpleGraph)
    # write header line
    dir = is_directed(g)? "d" : "u"
    line = join([nv(g), ne(g), dir, graphname], ",")
    write(io, "$line\n")
    # write edges
    for e in edges(g)
        write(io, "$(src(e)), $(dst(e))\n")
    end
    return 1
end

write(io::IO, g::Graph) = write(io, "Unnamed Graph", g)
write(io::IO, g::DiGraph) = write(io, "Unnamed DiGraph", g)

write(g::Graph) = write(STDOUT, "Unnamed Graph", g)
write(g::DiGraph) = write(STDOUT, "Unnamed DiGraph", g)


"""Writes a dictionary of (name=>graph) to a file `fn`,
with default `GZip` compression.

Returns number of graphs written.
"""
function write{S<:AbstractString, G<:SimpleGraph}(
    graphs::@compat(Dict{S, G}),
    fn::AbstractString;
    compress::Bool=true
)
    if compress
        f = GZip.open(fn,"w")
    else
        f = open(fn,"w")
    end
    ng = 0
    for (gname, g) in graphs
        ng += write(f, gname, g)
    end
    close(f)
    return ng
end

write(
    g::SimpleGraph,
    gname::AbstractString,
    fn::AbstractString;
    compress::Bool=true
) = write(@compat(Dict(gname=>g)), fn; compress=compress)

write(g::Graph, fn::AbstractString; compress::Bool=true) = write(g, "Unnamed Graph", fn; compress=compress)
write(g::DiGraph, fn::AbstractString; compress::Bool=true) = write(g, "Unnamed DiGraph", fn; compress=compress)

function _process_graphml(e::XMLElement, isdirected::Bool)
    nodes = @compat(Dict{AbstractString,Int}())
    edges = @compat(Vector{Edge}())

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
    graphs = @compat(Dict{AbstractString, SimpleGraph}())
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


"""
Writes a graph `g` with name `gname`
to a file `f` in the
[Gexf](http://en.wikipedia.org/wiki/GraphML) format.

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

"""
Writes a graph `g` with name `gname`
to a file `f` in the
[Gexf](http://gexf.net/format/) format.

Returns 1 (number of graphs written).
"""
function writegexf(f::IO, g::SimpleGraph)
    xdoc = XMLDocument()
    xroot = create_root(xdoc, "gexf")
    set_attribute(xroot,"xmlns","http://www.gexf.net/1.2draft")
    set_attribute(xroot,"version","1.2")
    set_attribute(xroot,"xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
    set_attribute(xroot,"xsi:schemaLocation","http://www.gexf.net/1.2draft/gexf.xsd")

    xmeta = new_child(xroot, "meta")
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

writegexf(g::SimpleGraph) = writegexf(STDOUT, g)

function writegexf(fname::AbstractString, g::SimpleGraph)
    f = open(fname, "w")
     writegexf(f, g)
     close(f)
     return 1
 end


function _readonedot(pg::ParserCombinator.Parsers.DOT.Graph)
    isdir = pg.directed
    nvg = length(Parsers.DOT.nodes(pg))
    nodedict = Dict(zip(collect(Parsers.DOT.nodes(pg)), 1:nvg))
    if isdir
        g = DiGraph(nvg)
    else
        g = Graph(nvg)
    end
    for es in Parsers.DOT.edges(pg)
        s = nodedict[es[1]]
        d = nodedict[es[2]]
        add_edge!(g, s, d)
    end
    return g
end

"""Returns a dictionary (name=>graph) from file `fn` stored in
[DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)) format.
Can optionally restrict to a single graph by specifying a name in gname.
"""
function readdot(filename::AbstractString, gname::AbstractString="")
    f = open(readall,filename)
    p = Parsers.DOT.parse_dot(f)

    graphs = @compat(Dict{AbstractString, SimpleGraph}())

    for pg in p
        isdir = pg.directed
        possname = isdir? Parsers.DOT.StringID("Unnamed DiGraph") : Parsers.DOT.StringID("Unnamed Graph")
        name = get(pg.id, possname).id
        if (gname == "") || (name == gname)
             graphs[name] = _readonedot(pg)
        end
    end
    return graphs
end
