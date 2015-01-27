# The format of simplegraph files is as follows:
# a one line header: <num_vertices>, {"d" | "u"}
#   - num_vertices is an integer
#   - "d" for directed graph, "u" for undirected. Note that this
#       option does not perform any additional edge construction; it's
#       merely used to return the correct type of graph.
# header followed by a list of (comma-delimited) edges - src,dst.

function readsimplegraph(fn::AbstractString)
    readedges = Set{(Int,Int)}()
    directed = true
    f = GZip.open(fn,"r")        # will work even if uncompressed
    line = chomp(readline(f))
    nstr, dirundir  = split (line,r"\s*,\s*")
    n = int(nstr)
    if dirundir == "u"
        directed = false
    end

    if directed
        g = SimpleDiGraph(n)
    else
        g = SimpleGraph(n)
    end
    while !eof(f)
        line = chomp(readline(f))
        src_s, dst_s = split(line,r"\s*,\s*")
        src = int(src_s)
        dst = int(dst_s)
        add_edge!(g, src, dst)
    end
    return g
end

function write(io::IO, g::AbstractSimpleGraph)
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

write(g::AbstractSimpleGraph) = write(STDOUT, g)

function write(
    g::AbstractSimpleGraph,
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
