*LightGraphs.jl* provides the following matrix operations on both directed and
undirected graphs:

### Adjacency
`adjacency_matrix(g[, dir, T])`  
Returns a sparse boolean adjacency matrix for a graph, indexed by `[src, dst]`
vertices. `True` values indicate an edge between `src` and `dst`. Users may
specify a direction (`:in`, `:out`, or `:both` are currently supported; `:out`
is default for both directed and undirected graphs) and a data type for the
matrix (defaults to `Int`).

`adjacency_spectrum(g[, dir, T])`  
Returns the eigenvalues of the adjacency matrix for a graph `g`, indexed by
vertex. Warning: Converts the matrix to dense with nv^2 memory usage. Use `eigs(adjacency_matrix(g);kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as
`adjacency_matrix`, above.


### Laplacian

`laplacian_matrix(g[, dir, T])`
Returns a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix)
for a graph `g`, indexed by `[src, dst]` vertices. For undirected graphs, `dir`
defaults to `:out`; for directed graphs, `dir` defaults to `:both`. `T`
defaults to `Int` for both graph types.

`laplacian_spectrum(g[, dir, T])`  
Returns the eigenvalues of the Laplacian matrix for a graph `g`, indexed by
vertex. Warning: Converts the matrix to dense with nv^2 memory usage. Use
`eigs(laplacian_matrix(g);  kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as
`laplacian_matrix`, above.
