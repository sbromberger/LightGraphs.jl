
<a id='Linear-Algebra-1'></a>

# Linear Algebra


*LightGraphs.jl* provides the following matrix operations on both directed and undirected graphs:


<a id='Adjacency-1'></a>

## Adjacency

<a id='LightGraphs.adjacency_matrix' href='#LightGraphs.adjacency_matrix'>#</a>
**`LightGraphs.adjacency_matrix`** &mdash; *Function*.



Returns a sparse boolean adjacency matrix for a graph, indexed by `[src, dst]` vertices. `true` values indicate an edge between `src` and `dst`. Users may specify a direction (`:in`, `:out`, or `:both` are currently supported; `:out` is default for both directed and undirected graphs) and a data type for the matrix (defaults to `Int`).

Note: This function is optimized for speed.

<a id='LightGraphs.adjacency_spectrum' href='#LightGraphs.adjacency_spectrum'>#</a>
**`LightGraphs.adjacency_spectrum`** &mdash; *Function*.



Returns the eigenvalues of the adjacency matrix for a graph `g`, indexed by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Use `eigs(adjacency_matrix(g);kwargs...)` to compute some of the eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as `adjacency_matrix`.


<a id='Laplacian-1'></a>

## Laplacian

<a id='LightGraphs.laplacian_matrix' href='#LightGraphs.laplacian_matrix'>#</a>
**`LightGraphs.laplacian_matrix`** &mdash; *Function*.



Returns a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix) for a graph `g`, indexed by `[src, dst]` vertices. For undirected graphs, `dir` defaults to `:out`; for directed graphs, `dir` defaults to `:both`. `T` defaults to `Int` for both graph types.

<a id='LightGraphs.laplacian_spectrum' href='#LightGraphs.laplacian_spectrum'>#</a>
**`LightGraphs.laplacian_spectrum`** &mdash; *Function*.



Returns the eigenvalues of the Laplacian matrix for a graph `g`, indexed by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Use `eigs(laplacian_matrix(g);  kwargs...)` to compute some of the eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as `laplacian_matrix`.

