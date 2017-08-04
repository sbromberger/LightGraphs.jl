@deprecate in_edges in_neighbors
@deprecate out_edges out_neighbors
@deprecate adjacency_matrix(g::AbstractGraph, dir::Symbol, T::DataType) adjacency_matrix(g, T; dir=dir)
@deprecate laplacian_matrix(g::AbstractGraph, dir::Symbol, T::DataType) laplacian_matrix(g, T; dir=dir)
@deprecate laplacian_spectrum(g::AbstractGraph, dir::Symbol) laplacian_spectrum(g; dir=dir)