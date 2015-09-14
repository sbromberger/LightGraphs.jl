"""Returns a sparse boolean adjacency matrix for a graph, indexed by `[src, dst]`
vertices. `true` values indicate an edge between `src` and `dst`. Users may
specify a row-major (`:byrow`, default) or column-major(`:bycol`) representation via `major`.
Users may also specify a data type for the matrix (defaults to `Int`).

Note: This function is optimized for speed.
"""
function adjacency_matrix(g::AbstractSparseGraph, major::Symbol=:byrow, T::DataType=Int)
    major == :byrow && return bmat(g) * one(T)
    major == :bycol  && return fmat(g) * one(T)

    error("Not implemented")
end

"""Returns a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix)
for a graph `g`, indexed by `[src, dst]` vertices. For both directed and undirected
graphs, `major` defaults to `:byrow` and `T` defaults to `Int`.
"""
function laplacian_matrix(g::Graph, major::Symbol=:byrow, T::DataType=Int)
    A = adjacency_matrix(g, major, T)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

function laplacian_matrix(g::DiGraph, major::Symbol=:byrow, T::DataType=Int)
    A = adjacency_matrix(g, major, T)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

doc"""Returns the eigenvalues of the Laplacian matrix for a graph `g`, indexed
by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Uses
`eigs(laplacian_matrix(g);  kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `major` and `T` are the same as
`laplacian_matrix`.
"""
laplacian_spectrum(g::SimpleGraph, major::Symbol=:byrow, T::DataType=Int) = eigvals(full(laplacian_matrix(g, major, T)))

doc"""Returns the eigenvalues of the adjacency matrix for a graph `g`, indexed
by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Uses
`eigs(adjacency_matrix(g);kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `T` are the same as `adjacency_matrix`.
"""
adjacency_spectrum(g::Graph, T::DataType=Int) = eigvals(full(adjacency_matrix(g, :byrow, T)))

function adjacency_spectrum(g::DiGraph, T::DataType=Int)
    A = adjacency_matrix(g, :byrow, T)
    B = adjacency_matrix(g, :bycol, T)
    return eigvals(full(A + B))
end

# GraphMatrices integration


function CombinatorialAdjacency(g::Graph)
    isdefined(:GraphMatrices) || error("GraphMatrices.jl is required for this function.\nYou must recompile LightGraphs after installing GraphMatrices.")
    d = float(indegree(g))
    return CombinatorialAdjacency{Float64, typeof(g), typeof(d)}(g,d)
end
