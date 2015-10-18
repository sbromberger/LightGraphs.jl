"""Returns a sparse boolean adjacency matrix for a graph, indexed by `[src, dst]`
vertices. `true` values indicate an edge between `src` and `dst`. Users may
specify a direction (`:in`, `:out`, or `:both` are currently supported; `:out`
is default for both directed and undirected graphs) and a data type for the
matrix (defaults to `Int`).

Note: This function is optimized for speed.
"""
function adjacency_matrix(g::SimpleGraph, dir::Symbol=:out, T::DataType=Int)
    n_v = nv(g)
    nz = ne(g) * (is_directed(g)? 1 : 2)
    colpt = ones(Int, n_v + 1)

    if dir == :out
        neighborfn = out_neighbors
    elseif dir == :in
        neighborfn = in_neighbors
    elseif dir == :both
        if is_directed(g)
            neighborfn = all_neighbors
            nz *= 2
        else
            neighborfn = out_neighbors
        end
    else
        error("Not implemented")
    end
    rowval = sizehint!(Vector{Int}(), nz)
    for j in 1:n_v
        dsts = neighborfn(g, j)
        colpt[j+1] = colpt[j] + length(dsts)
        append!(rowval, sort!(dsts))
    end
    return SparseMatrixCSC(n_v,n_v,colpt,rowval,ones(T,nz))
end

"""Returns a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix)
for a graph `g`, indexed by `[src, dst]` vertices. For undirected graphs, `dir`
defaults to `:out`; for directed graphs, `dir` defaults to `:both`. `T`
defaults to `Int` for both graph types.
"""
function laplacian_matrix(g::Graph, dir::Symbol=:out, T::DataType=Int)
    A = adjacency_matrix(g, dir, T)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

function laplacian_matrix(g::DiGraph, dir::Symbol=:both, T::DataType=Int)
    A = adjacency_matrix(g, dir, T)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

doc"""Returns the eigenvalues of the Laplacian matrix for a graph `g`, indexed
by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Use
`eigs(laplacian_matrix(g);  kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as
`laplacian_matrix`.
"""
laplacian_spectrum(g::Graph, dir::Symbol=:out, T::DataType=Int) = eigvals(full(laplacian_matrix(g, dir, T)))
laplacian_spectrum(g::DiGraph, dir::Symbol=:both, T::DataType=Int) = eigvals(full(laplacian_matrix(g, dir, T)))

doc"""Returns the eigenvalues of the adjacency matrix for a graph `g`, indexed
by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Use
`eigs(adjacency_matrix(g);kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as
`adjacency_matrix`.
"""
adjacency_spectrum(g::Graph, dir::Symbol=:out, T::DataType=Int) = eigvals(full(adjacency_matrix(g, dir, T)))
adjacency_spectrum(g::DiGraph, dir::Symbol=:both, T::DataType=Int) = eigvals(full(adjacency_matrix(g, dir, T)))



# GraphMatrices integration


function CombinatorialAdjacency(g::Graph)
    isdefined(:GraphMatrices) || error("GraphMatrices.jl is required for this function.\nYou must recompile LightGraphs after installing GraphMatrices.")
    d = float(indegree(g))
    return CombinatorialAdjacency{Float64, typeof(g), typeof(d)}(g,d)
end
