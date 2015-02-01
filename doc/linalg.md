*LightGraphs.jl* provides the following matrix operations on undirected graphs:

### Adjacency
`adjacency_matrix(g)`  
Returns a sparse boolean adjacency matrix for a graph, indexed by `[src, dst]` vertices. `True` values indicate an edge between `src` and `dst`.

`adjacency_spectrum(g)`  
Returns the eigenvalues of the adjacency matrix for a graph, indexed by vertex.


### Laplacian

`laplacian_matrix(g)`  
Returns a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix) for a graph, indexed by `[src, dst]` vertices.

`laplacian_spectrum(g)`  
Returns the eigenvalues of the Laplacian matrix for a graph, indexed by vertex.
