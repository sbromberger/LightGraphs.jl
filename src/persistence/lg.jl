# The format of simplegraph files is as follows:
# a one line header: <num_vertices>, <num_edges>, {"d" | "u"}, <name>[, <ver>, <datatype>, <graphcode>]
#   - num_vertices is an integer
#   - num_edges is an integer
#   - "d" for directed graph, "u" for undirected. Note that this
#       option does not perform any additional edge construction; it's
#       merely used to return the correct type of graph.
#   - name is a string
#   - ver is optional and is an int
#   - datatype is mandatory if version is set and is a string ("UInt8", etc.)
#   - graphcode is mandatory if version is set and is a string.
# header followed by a list of (comma-delimited) edges - src,dst.
# Multiple graphs may be present in one file.


struct LGFormat <: AbstractGraphFormat end

struct LGHeader
    nv::Int
    ne::Int
    is_directed::Bool
    name::String
    ver::Int
    dtype::DataType
    code::String
end
function show(io::IO, h::LGHeader)
    isdir = h.is_directed? "d" : "u"
    print(io, "$(h.nv),$(h.ne),$isdir,$(h.name),$(h.ver),$(h.dtype),$(h.code)")
end

LGHeader(nv::Int, ne::Int, is_directed::Bool, name::AbstractString) = 
    LGHeader(nv, ne, is_directed, name, 1, Int64, "simplegraph")

function _lg_read_one_graph(f::IO, header::LGHeader)
    T = header.dtype
    if header.is_directed
        g = DiGraph{T}(header.nv)
    else
        g = Graph{T}(header.nv)
    end
    for i = 1:header.ne
        line = chomp(readline(f))
        if length(line) > 0
            src_s, dst_s = split(line, r"\s*,\s*")
            src = parse(T, src_s)
            dst = parse(T, dst_s)
            add_edge!(g, src, dst)
        end
    end
    return g
end

function _lg_skip_one_graph(f::IO, n_e::Integer)
    for _ in 1:n_e
        readline(f)
    end
end

function _parse_header(s::AbstractString)
    addl_info = false
    nvstr, nestr, dirundir, graphname = split(s, r"s*,s*", limit=4)
    if contains(graphname, ",") # version number and type
        graphname, _ver, _dtype, graphcode = split(graphname, r"s*,s*")
        ver = parse(Int, _ver)
        dtype = eval(Symbol(_dtype))
        addl_info = true
    end
    n_v = parse(Int, nvstr)
    n_e = parse(Int, nestr)
    dirundir = strip(dirundir)
    directed = !(dirundir == "u")
    graphname = strip(graphname)
    if !addl_info
        header = LGHeader(n_v, n_e, directed, graphname)
    else
        header = LGHeader(n_v, n_e, directed, graphname, ver, dtype, graphcode)
    end
    return header
end





    
"""
    loadlg_mult(io)

Return a dictionary of (name=>graph) loaded from IO stream `io`.
"""
function loadlg_mult(io::IO)
    graphs = Dict{String,AbstractGraph}()
    while !eof(io)
        line = strip(chomp(readline(io)))
        if startswith(line, "#") || line == ""
            next
        else
            header = _parse_header(line)
            g = _lg_read_one_graph(io, header)
            graphs[header.name] = g
        end
    end
    return graphs
end

function loadlg(io::IO, gname::String)
    while !eof(io)
        line = strip(chomp(readline(io)))
        (startswith(line, "#") || line == "") && continue
        header = _parse_header(line)
        if gname == header.name
            return _lg_read_one_graph(io, header)
        else
            _lg_skip_one_graph(io, header.ne)
        end
    end
    error("Graph $gname not found")
end

"""
    savelg(io, g, gname)

Write a graph `g` with name `gname` in a proprietary format
to the IO stream designated by `io`. Return 1 (number of graphs written).
"""
function savelg(io::IO, g::AbstractGraph{T}, gname::String) where T
    header = LGHeader(nv(g), ne(g), is_directed(g), gname, 2, T, "simplegraph")
    # write header line
    line = string(header)
    write(io, "$line\n")
    # write edges
    for e in edges(g)
        write(io, "$(src(e)),$(dst(e))\n")
    end
    return 1
end

"""
    savelg_mult(io, graphs)

Write a dictionary of (name=>graph) to an IO stream `io`,
with default `GZip` compression. Return number of graphs written.
"""
function savelg_mult(io::IO, graphs::Dict)
    ng = 0
    for (gname, g) in graphs
        ng += savelg(io, g, gname)
    end
    return ng
end


loadgraph(io::IO, gname::String, ::LGFormat) = loadlg(io, gname)
loadgraphs(io::IO, ::LGFormat) = loadlg_mult(io)
savegraph(io::IO, g::AbstractGraph, gname::String, ::LGFormat) = savelg(io, g, gname)
savegraph(io::IO, g::AbstractGraph, ::LGFormat) = savelg(io, g, "graph")
savegraph(io::IO, d::Dict, ::LGFormat) = savelg_mult(io, d)
