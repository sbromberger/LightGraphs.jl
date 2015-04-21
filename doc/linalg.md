*LightGraphs.jl* provides the following matrix operations on undirected graphs:

### Adjacency
`adjacency_matrix(g)`  
Returns a sparse boolean adjacency matrix for a graph, indexed by `[src, dst]` vertices. `True` values indicate an edge between `src` and `dst`.

`adjacency_spectrum(g)`  
Returns the eigenvalues of the adjacency matrix for a graph, indexed by vertex. Warning: Converts the matrix to dense with nv^2 memory usage. Use `eigs(adjacency_matrix(g);kwargs...)` to compute some of the eigenvalues/eigenvectors.


### Laplacian

`laplacian_matrix(g)`  
Returns a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix) for a graph, indexed by `[src, dst]` vertices.

`laplacian_spectrum(g)`  
Returns the eigenvalues of the Laplacian matrix for a graph, indexed by vertex. Warning: Converts the matrix to dense with nv^2 memory usage. Use `eigs(laplacian_matrix(g);kwargs...)` to compute some of the eigenvalues/eigenvectors.


### PageRank
`pagerank(g[, α=0.85, n=100, ϵ = 1.0e-6)])`  
Returns a vector of floating-point values corresponding to the
[PageRank](http://en.wikipedia.org/wiki/PageRank) values for graph *g*, indexed
by vertex. Optional parameters include the dampening factor *α*, the maximum
number of iterations *n*, and the tolerance threshold *ϵ*. The function will
throw an error if convergence is unsuccessful after *n* iterations.
