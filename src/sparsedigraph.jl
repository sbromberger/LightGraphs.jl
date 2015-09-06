SparseDiGraph(n::Int) = SparseDiGraph(
    Set{Edge}(),
    spzeros(Float64,n,n),
    spzeros(Float64,n,n)
)

function SparseDiGraph(g::DiGraph)
    fm = adjacency_matrix(g, :bycol, Bool)
    fmt = adjacency_matrix(g, :byrow, Bool)
    return SparseDiGraph(copy(g.edges), fmt, fm)
end


# fm and bm are CSCSparseMatrices, so it is more performant to make
# things column-major. That's why this looks backwards.
function add_edge!(g::SparseDiGraph, e::Edge)
    g.fm[dst(e),src(e)] = true
    g.bm[src(e),dst(e)] = true
    push!(g.edges, e)
end
