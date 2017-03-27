using JLD
"""
    GraphSerializer

GraphSerializer is a type for custom serialization into JLD files.
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
mutable struct GraphSerializer
    vertices::UnitRange{Int}
    ne::Int
    packed_adjlist::Vector{Int}
    n_adjlist::Vector{Int} #stores the end offset into packed_adjlist
end

function JLD.writeas(g::Graph)
    n_adjlist = zeros(Int,nv(g))
    @assert sum(degree(g))/2 == ne(g)
    packed_adjlist = Vector{Int}(2*ne(g))
    k = 0
    degree(g), sum(degree(g))
    for (i,lst) in enumerate(g.fadjlist)
        #create the offsets
        if i != 1
            n_adjlist[i] = n_adjlist[i-1] + length(lst)
        else
            n_adjlist[1] = length(lst)
        end

        # pack the neighbors
        for v in lst
            packed_adjlist[k+=1] = v
        end
    end
    GraphSerializer(vertices(g), ne(g), packed_adjlist, n_adjlist)
end

function JLD.readas(gs::GraphSerializer)
    n = length(gs.vertices)
    adj = Vector{Vector{Int}}(n)
    @assert length(adj) == n
    for i in gs.vertices
        if i == 1
            posbegin = 1
        else
            posbegin = gs.n_adjlist[i-1] +1
        end
        posend   = gs.n_adjlist[i]
        adj[i] = gs.packed_adjlist[posbegin:posend]
    end
    @assert sum(map(length, adj)) == 2gs.ne
    g = Graph(gs.ne, adj)
    return g
end

mutable struct Network{G,V,E}
    graph::G
    vprop::Vector{V}
    eprop::Dict{Edge,E}
end

import Base.==

==(n::Network, m::Network) = (n.graph == m.graph) && (n.vprop == m.vprop) && (n.eprop == m.eprop)
