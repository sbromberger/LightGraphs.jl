abstract type AbstractGraphFormat end

"""
    loadgraph(file, gname="graph", format=LGFormat())

Read a graph named `gname` from `file` in the format `format`.

### Implementation Notes
`gname` is graph-format dependent and is only used if the file contains
multiple graphs; if the file format does not support multiple graphs, this
value is ignored. The default value may change in the future.
"""
function loadgraph(fn::AbstractString, gname::AbstractString, format::AbstractGraphFormat)
    open(fn, "r") do io
        loadgraph(auto_decompress(io), gname, format)
    end
end
loadgraph(fn::AbstractString) = loadgraph(fn, "graph", LGFormat())
loadgraph(fn::AbstractString, gname::AbstractString) = loadgraph(fn, gname, LGFormat())
loadgraph(fn::AbstractString, format::AbstractGraphFormat) = loadgraph(fn, "graph", format)


"""
    loadgraphs(file, format=LGFormat())

Load multiple graphs from `file` in the format `format`.
Return a dictionary mapping graph name to graph.

### Implementation Notes
For unnamed graphs the default name \"graph\" will be used. This default
may change in the future.
"""
function loadgraphs(fn::AbstractString, format::AbstractGraphFormat)
    open(fn, "r") do io
        loadgraphs(auto_decompress(io), format)
    end
end

loadgraphs(fn::AbstractString) = loadgraphs(fn, LGFormat())

function auto_decompress(io::IO)
    format = :raw
    mark(io)
    if !eof(io)
        b1 = read(io, UInt8)
        if !eof(io)
            b2 = read(io, UInt8)
            if (b1, b2) == (0x1f, 0x8b)  # check magic bytes
                format = :gzip
            end
        end
    end
    reset(io)
    if format == :gzip
        io = CodecZlib.GzipDecompressorStream(io)
    end
    return io
end


"""
    savegraph(file, g, gname="graph", format=LGFormat; compress=true)

Saves a graph `g` with name `gname` to `file` in the format `format`.
If `compress = true`, use GZip compression when writing the file.
Return the number of graphs written.

### Implementation Notes
The default graph name assigned to `gname` may change in the future.
"""
function savegraph(fn::AbstractString, g::AbstractGraph, gname::AbstractString,
        format::AbstractGraphFormat; compress=true
    )
    io = open(fn, "w")
    try
        if compress
            io = CodecZlib.GzipCompressorStream(io)
        end
        return savegraph(io, g, gname, format)
    catch
        rethrow()
    finally
        close(io)
    end
end

savegraph(fn::AbstractString, g::AbstractGraph, gname::AbstractString="graph", format=LGFormat(); compress=true) =
    savegraph(fn, g, gname, LGFormat, compress=compress)

savegraph(fn::AbstractString, g::AbstractGraph, format::AbstractGraphFormat; compress=true) =
    savegraph(fn, g, "graph", format, compress=compress)
"""
    savegraph(file, g, d, format=LGFormat; compress=true)

Save a dictionary of `graphname => graph` to `file` in the format `format`.
If `compress = true`, use GZip compression when writing the file.
Return the number of graphs written.

### Implementation Notes
Will only work if the file format supports multiple graph types.
"""
function savegraph(fn::AbstractString, d::Dict{T,U},
    format::AbstractGraphFormat; compress=true) where T<:AbstractString where U<:AbstractGraph
    io = open(fn, "w")
    try
        if compress
            io = CodecZlib.GzipCompressorStream(io)
        end
        return savegraph(io, d, format)
    catch
        rethrow()
    finally
        close(io)
    end
end

savegraph(fn::AbstractString, d::Dict; compress=true) = savegraph(fn, d, LGFormat(), compress=compress)
