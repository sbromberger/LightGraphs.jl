

# TODO: implement save

function _dot_read_one_graph(pg::ParserCombinator.Parsers.DOT.Graph)
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

function loaddot(io::IO, gname::AbstractString)
    p = Parsers.DOT.parse_dot(readall(io))
    for pg in p
        isdir = pg.directed
        possname = isdir? Parsers.DOT.StringID("digraph") : Parsers.DOT.StringID("graph")
        name = get(pg.id, possname).id
        name == gname && return _dot_read_one_graph(pg)
    end
    error("Graph $gname not found")
end

function loaddot_mult(io::IO)
    p = Parsers.DOT.parse_dot(readall(io))

    graphs = Dict{AbstractString, SimpleGraph}()

    for pg in p
        isdir = pg.directed
        possname = isdir? Parsers.DOT.StringID("digraph") : Parsers.DOT.StringID("graph")
        name = get(pg.id, possname).id
        graphs[name] = _dot_read_one_graph(pg)
    end
    return graphs
end

filemap[:dot] = (loaddot, loaddot_mult, NI, NI)
