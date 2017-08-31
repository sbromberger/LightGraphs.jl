module LinAlg

using SimpleTraits
using ..LightGraphs

import LightGraphs: IsDirected, adjacency_matrix, laplacian_matrix, laplacian_spectrum

import Base: convert, sparse, size, diag, eltype, ndims, ==, *, .*, issymmetric, A_mul_B!, length, Diagonal


export convert,
    SparseMatrix,
    GraphMatrix,
    Adjacency,
    adjacency,
    Laplacian,
    CombinatorialAdjacency,
    CombinatorialLaplacian,
    NormalizedAdjacency,
    NormalizedLaplacian,
    StochasticAdjacency,
    StochasticLaplacian,
    AveragingAdjacency,
    AveragingLaplacian,
    PunchedAdjacency,
    Noop,
    diag,
    degrees,
    symmetrize,
    prescalefactor,
    postscalefactor,
    perron,

    non_backtracking_matrix,
    Nonbacktracking,
    contract!,
    contract,

    adjacency_matrix,
    laplacian_matrix,
    incidence_matrix,
    adjacency_spectrum,
    laplacian_spectrum,
    coo_sparse,
    spectral_distance


include("./graphmatrices.jl")
include("./spectral.jl")
include("./nonbacktracking.jl")


end

