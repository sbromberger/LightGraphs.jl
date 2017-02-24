
# Inspired by NetworkX
function _getN(N::Array{Int})
    if N[1] <= 62 return N[1]
    elseif N[2] <= 62 return (N[2]<<12) + (N[3]<<6) + N[4]
    else
        return (N[3]<<30) + (N[4]<<24) + (N[5]<<18) +
            (N[6]<<12) + (N[7]<<6) + N[8]
    end
end

# Inspired by NetworkX
function _calcN(n::Int)
    if n < 0 error("n must be positive")
    elseif n <= 62 return [n]
    elseif n <= 258047 return [63, (n>>12) & 0x3f, (n>>6) & 0x3f, n & 0x3f]
    elseif n <= 68719476735
        return [63, 63,
            (n>>30) & 0x3f, (n>>24) & 0x3f, (n>>18) & 0x3f,
            (n>>12) & 0x3f, (n>>6) & 0x3f, n & 0x3f]
    else
        error("n must be less than 68719476736")
    end
end

function _calcBytes(A::AbstractArray{Bool,2})
    n = size(A,1)
    nbits = div(n * n-1, 2)
    nBytes = cld(nbits, 6)
    bytevec = Vector{UInt8}(nBytes)

    ind = 0
    acc = 0
    for col = 1:n, row = 1:(col-1)
        ind += 1
        acc = (acc << 1) + A[row, col]
        if (ind % 6) == 0
            bytevec[div(ind,6)] = acc
            acc = 0
        end
    end

    acc = acc << (6 - ind % 6)
    bytevec[end] = acc

    bytevec .+ 63
end







"""
Writes a graph `g` to a file `f` in the [Graph6](http://users.cecs.anu.edu.au/%7Ebdm/data/formats.txt) format.
Returns 1 (number of graphs written).
"""
function savegraph6(f::IO, g::SimpleGraph, gname::String = "g")
    str = ">>graph6<<"
    N = _calcN(nv(g))
    bytes = _calcBytes(adjacency_matrix(g, Bool))
    str = join([str, String(bytes)])

    println(f, str)
    return 1
end


"""Reads a graph from file `fname` in the [Pajek
 NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.
 Returns 1 (number of graphs written).
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
