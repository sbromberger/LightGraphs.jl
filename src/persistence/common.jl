NI(x...) = error("This function is not implemented.")

@deprecate readgraph load

const filemap = Dict{Symbol, Tuple{Function, Function, Function, Function}}()
        # :gml        => (loadgml, loadgml_mult, savegml, savegml_mult)
        # :graphml    => (loadgraphml, loadgraphml_mult, savegraphml, savegraphml_mult)
        # :md         => (loadmatrixdepot, NOTIMPLEMENTED, NOTIMPLEMENTED, NOTIMPLEMENTED)

# load a single graph by name
"""Loads a single graph from stream `io` with name `gname` and graph type `t`.
"""
function load(io::IO, gname::AbstractString, t::Symbol=:lg)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][1](io, gname)
end

"""Loads multiple graphs of type `t` from stream `io`. Returns a dictionary
mapping graph name to graph."""
function load(io::IO, t::Symbol=:lg)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][2](io)
end

"""Saves a single graph `g` with name `gname` to stream `io` using graph type `t`.
Returns the number of graphs written (1)."""
function save(io::IO, g::SimpleGraph, gname::AbstractString, t::Symbol=:lg)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][3](io, g, gname)
end

# save a single graph without name
save(io::IO, g::Graph, t::Symbol=:lg) = save(io, g, "Unnamed Graph", t)
save(io::IO, g::DiGraph, t::Symbol=:lg) = save(io, g, "Unnamed DiGraph", t)

# save a dictionary of graphs {"name" => graph}
"""Saves multiple graphs in a dictionary mapping graph name to graph to stream
`io` using graph type `t`."""
function save(io::IO, d::Dict{AbstractString, SimpleGraph}, t::Symbol=:lg)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][4](io, d)
end

# load from a file
function load(fn::AbstractString, x...)
    GZip.open(fn,"r") do io
        load(io, x...)
    end
end

# save to a file
function save(fn::AbstractString, x...; compress::Bool=false)
    if compress
        io = GZip.open(fn,"w")
    else
        io = open(fn,"w")
    end
    retval = save(io, x...)
    close(io)
    return retval
end
