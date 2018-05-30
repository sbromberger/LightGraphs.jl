module LinAlg

using SimpleTraits
import SparseArrays
import LinearAlgebra
import IterativeEigensolvers
using ..LightGraphs

import LightGraphs: IsDirected, AbstractGraph, inneighbors,
outneighbors, all_neighbors, is_directed, nv, ne, has_edge, vertices

import Base: convert, size, eltype, ndims, ==, *, .*, length
import SparseArrays: sparse, diag
import LinearAlgebra: issymmetric, mul!, Diagonal

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

