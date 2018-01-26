@deprecate in_edges inneighbors
@deprecate out_edges outneighbors
@deprecate in_neighbors inneighbors
@deprecate out_neighbors outneighbors
@deprecate all_neighbors allneighbors
@deprecate adjacency_matrix(g::AbstractGraph, dir::Symbol, T::DataType) adjacency_matrix(g, T; dir=dir)
@deprecate adjacency_matrix(g::AbstractGraph, dir::Symbol) adjacency_matrix(g; dir=dir)
@deprecate laplacian_matrix(g::AbstractGraph, dir::Symbol, T::DataType) laplacian_matrix(g, T; dir=dir)
@deprecate laplacian_matrix(g::AbstractGraph, dir::Symbol) laplacian_matrix(g; dir=dir)
@deprecate laplacian_spectrum(g::AbstractGraph, dir::Symbol) laplacian_spectrum(g; dir=dir)

