SparseGraph(n) = SparseGraph(
    Set{Edge}(),
    spzeros(Float64,n,n),
    spzeros(Float64,n,n)
)

function SparseGraph(g::Graph)
    fm = adjacency_matrix(g, :bycol, Bool)
    fmt = adjacency_matrix(g, :byrow, Bool)
    return SparseGraph(copy(g.edges), fm, fmt)
end

# fm and bm are CSCSparseMatrices, so it is more performant to make
# things column-major. That's why this looks backwards.
function add_edge!(g::SparseGraph, e::Edge)
    g.fm[dst(e),src(e)] = true
    g.fm[src(e),dst(e)] = true

    g.bm[src(e),dst(e)] = true
    g.bm[dst(e),src(e)] = true
    push!(g.edges, e)
end

has_edge(g::SparseDiGraph, e::Edge) = g.fm[dst(e),src(e)] || g.fm[src(e),dst(e)]
