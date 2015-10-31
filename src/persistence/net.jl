"""
Writes a graph `g` to a file `f` in the [Pajek
NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.

Returns 1 (number of graphs written).
"""
function writenet(f::IO, g::SimpleGraph)
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

"""
Writes a graph `g` to STDOUT in the [Pajek
NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.

Returns 1 (number of graphs written).
"""
writenet(g::SimpleGraph) = writenet(STDOUT, g)

"""
Writes a graph `g` to a file `fname` in the [Pajek
NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.

Returns 1 (number of graphs written).
"""
function writenet(fname::AbstractString, g::SimpleGraph)
    f = open(fname, "w")
     writenet(f, g)
     close(f)
     return 1
 end

"""Reads a graph from file `fname` in the [Pajek
 NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.

 Returns 1 (number of graphs written).
"""
function readnet(fname::AbstractString)
     f = open(fname, "r")
     line =readline(f)
     n = parse(Int,split(line," ")[2])
     for fline in eachline(f)
         line = fline
         (ismatch(r"^\*Arcs",line) || ismatch(r"^\*Edges",line)) && break
     end
     if ismatch(r"^\*Arcs",line)
         g = DiGraph(n)
     else
         g = Graph(n)
     end
     for fline in eachline(f)
         line = fline
         m = matchall(r"\d+",line)
         length(m) < 2 && break
          add_edge!(g, parse(Int, m[1]), parse(Int, m[2]))
     end
     if ismatch(r"^\*Edges",line) # add edges to a DiGraph
         for fline in eachline(f)
             line = fline
             m = matchall(r"\d+",line)
             length(m) < 2 && break
             i1,i2 = parse(Int, m[1]), parse(Int, m[2])
             add_edge!(g, i1, i2)
             add_edge!(g, i2, i1)
         end
     end
     close(f)
     return g
 end
