"""GraphSerializer is a type for custom serialization into JLD files.
It has no use except on disk. This type supports JLD.writeas(g::Graph)
and JLD.readas(gs::GraphSerializer). It is a form of Compressed Sparse Column format
of the adjacency matrix of a graph g.

Fields
======
vertices: the UnitRange of vertex numbers
ne: the number of edges in g
packed_adjlist: the concatenation of fadj into a 1D array
n_adjlist: the degree of each vertex. use cumsum(n_adjlist) to get the CSC offsets.

This type compacts the adjacency matrix into a 1D structure so that it can be represented on disk.
We do not use CSC/CSR for graphs because we need amortized O(1) insertion, and CSC provides O(n)
insertion because you have to shift entries in memory.

This format is fine for storage on disk because the data is not changing.
JLD.readas(gs::GraphSerializer) creates the adjacency list representation directly instead of calling add_edge!
repeatedly in an attempt to improve performance.

This type has not been tested with mmaped files or compression in JLD. 
"""
type GraphSerializer
    vertices::UnitRange{Int}
    ne::Int
    packed_adjlist::Vector{Int}
    n_adjlist::Vector{Int}
end

function JLD.writeas(g::Graph)
    n_adjlist = map(length, g.fadjlist)
    packed_adjlist = Array(Int, sum(n_adjlist))
    k = 0
    for lst in g.fadjlist
        for v in lst
            packed_adjlist[k+=1] = v
        end
    end
    GraphSerializer(g.vertices, g.ne, packed_adjlist, n_adjlist)
end

function JLD.readas(gs::GraphSerializer)
    n = length(gs.vertices)
    fadj = Vector{Vector{Int}}(n)
    posbegin=1
    for i in gs.vertices
        deg = gs.n_adjlist[i]
        posend = posbegin + deg - 1
        fadj[i] = gs.packed_adjlist[posi:posend]
        posbegin = posend + 1
    end
    @assert sum(map(length, fadj)) == gs.ne
    return Graph(n, gs.ne, fadj)
end
