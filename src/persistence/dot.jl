# TODO: implement writedot

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

    graphs = Dict{AbstractString, SimpleGraph}()

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
