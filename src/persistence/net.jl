
"""
Writes a graph `g` to a file `f` in the [Pajek
NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.
Returns 1 (number of graphs written).
"""
function savenet(f::IO, g::SimpleGraph, gname::String = "g")
    println(f, "*Vertices $(nv(g))")
    # write edges
    if is_directed(g)
        println(f, "*Arcs")
    else
        println(f, "*Edges")
    end
    for e in edges(g)
        println(f, "$(src(e)) $(dst(e))")
    end
    return 1
end


"""Reads a graph from file `fname` in the [Pajek
 NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.
 Returns the graph.
"""
function loadnet(f::IO, gname::String = "g")
    line =readline(f)
    # skip comments
    while startswith(line, "%")
        line =readline(f)
    end
    n = parse(Int, matchall(r"\d+",line)[1])
    for fline in eachline(f)
        line = fline
        (ismatch(r"^\*Arcs",line) || ismatch(r"^\*Edges",line)) && break
    end
    if ismatch(r"^\*Arcs",line)
        g = DiGraph(n)
    else
        g = Graph(n)
    end
    while ismatch(r"^\*Arcs",line)
        for fline in eachline(f)
            line = fline
            m = matchall(r"\d+",line)
            length(m) < 2 && break
            add_edge!(g, parse(Int, m[1]), parse(Int, m[2]))
        end
    end
    while ismatch(r"^\*Edges",line) # add edges in both directions
        for fline in eachline(f)
            line = fline
            m = matchall(r"\d+",line)
            length(m) < 2 && break
            i1,i2 = parse(Int, m[1]), parse(Int, m[2])
            add_edge!(g, i1, i2)
            add_edge!(g, i2, i1)
        end
    end
    return g
end

loadnet_mult(io::IO) = Dict("g" => loadnet(io))

filemap[:net] = (loadnet, loadnet_mult, savenet, NI)
