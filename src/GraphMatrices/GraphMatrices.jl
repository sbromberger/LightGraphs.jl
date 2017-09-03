module GraphMatrices

using SimpleTraits
using ..LightGraphs

import LightGraphs: IsDirected

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
    coo_sparse

include("./graphmatrix.jl")
include("./nonbacktracking.jl")
end

