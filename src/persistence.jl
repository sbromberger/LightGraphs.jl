# The format of simplegraph files is as follows:
# a one line header: <num_vertices>, {"d" | "u"}
#   - num_vertices is an integer
#   - "d" for directed graph, "u" for undirected. Note that this
#       option does not perform any additional edge construction; it's
#       merely used to return the correct type of graph.
# header followed by a list of (comma-delimited) edges - src,dst.

"Returns a graph loaded from file `fn`."
function readgraph(fn::AbstractString)
    readedges = Set{@compat Tuple{Int,Int}}()
    f = GZip.open(fn,"r")        # should work even if uncompressed
    line = chomp(readline(f))
    nstr, dirundir = split(line,r"\s*,\s*")
    n = parse(Int,nstr)
    directed = !(dirundir == "u")

    if directed
        g = DiGraph(n)
    else
        g = Graph(n)
    end
    while !eof(f)
        line = chomp(readline(f))
        if length(line) > 0
            src_s, dst_s = split(line,r"\s*,\s*")
            src = parse(Int, src_s)
            dst = parse(Int, dst_s)
            add_edge!(g, src, dst)
        end
    end
    return g
end

"""Writes a graph `g` in a proprietary format to the IO stream designated by
`io`.

Return tuples containing the number of vertices and
number of edges written.
"""
function write(io::IO, g::SimpleGraph)
    # write header line
    dir = is_directed(g)? "d" : "u"
    line = join([nv(g), dir], ",")
    write(io, "$line\n")
    # write edges
    for e in edges(g)
        write(io, "$(src(e)), $(dst(e))\n")
    end
    return (nv(g), ne(g))
end

write(g::SimpleGraph) = write(STDOUT, g)

"""Writes a graph to a file `fn`, with default `GZip` compression.

Return tuples containing the number of vertices and
number of edges written.
"""
function write(
    g::SimpleGraph,
    fn::AbstractString;
    compress=true)
    if compress
        f = GZip.open(fn,"w")
    else
        f = open(fn,"w")
    end

    res = write(f, g)
    close(f)
    return res
end



_HAS_LIGHTXML = try
        using LightXML
        true
    catch
        false
    end

if _HAS_LIGHTXML

function _process_graphml(e::XMLElement, isdirected::Bool)
    nodes = Dict{String,Int}()
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

#@doc """
#Reads in a GraphML file as an array of Graphs or Digraphs
#
#Input:
#
#    filename
#
#Returns:
#
#    An array of (name, SimpleGraph) tuple
#""" ->
doc"""Returns a graph from file `fn` stored in [GraphML](http://en.wikipedia.org/wiki/GraphML)
format.
"""
function readgraphml(filename::String)
    xdoc = parse_file(filename)
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "graphml" || error("Not a GraphML file")

    # traverse all its child nodes and print element names
    graphs = @compat(Vector{Tuple{String, SimpleGraph}}())
    for c in child_nodes(xroot)  # c is an instance of XMLNode
        if is_elementnode(c)
            e = XMLElement(c)  # this makes an XMLElement instance
            if name(e) == "graph"
                graphname = has_attribute(e, "id") ? attribute(e, "id") : nothing
                edgedefault = attribute(e, "edgedefault")
                isdirected = edgedefault=="directed" ? true :
                             edgedefault=="undirected" ? false : error("Unknown value of edgedefault: $edgedefault")
                g = _process_graphml(e, isdirected)
                push!(graphs, (graphname, g))
            else
                warn("Skipping unknown XML element $(name(e))")
            end
        end
    end
    return graphs
end

else

function readgraphml(filename::String)
    error("needs LightXML")
end

end

_HAS_PARSERCOMBINATOR = try
        using ParserCombinator
        using ParserCombinator.Parsers.GML
        true
    catch
        false
    end


# returns the first graph in a GML file. Note: this is not
# consistent with readgraphml and we should probably standardize.
if _HAS_PARSERCOMBINATOR
    function readgml(filename::String)
        f = open(readall,filename)
        p = parse_dict(f)
        g1 = p[:graph][1]
        dir = Bool(get(g1, :directed, 0))

        nodes = [x[:id] for x in g1[:node]]
        mapping = Dict{Int,Int}()
        for (i,n) in enumerate(nodes)
            mapping[n] = i
        end

        if dir
            g = DiGraph(length(nodes))
        else
            g = Graph(length(nodes))
        end
        sds = [(Int(x[:source]), Int(x[:target])) for x in g1[:edge]]
        for (s,d) in (sds)
            add_edge!(g, mapping[s], mapping[d])
        end
        return g
    end

else
    function readgml(filename::String)
        error("needs ParserCombinator")
    end
end
