module LinAlg

using ArnoldiMethod

using SimpleTraits
using SparseArrays: SparseMatrixCSC
import SparseArrays: blockdiag, sparse
using LinearAlgebra: I, Symmetric, diagm, dot, eigen, eigvals, norm, rmul!, tril, triu
import LinearAlgebra: Diagonal, diag, issymmetric, mul!

using ..LightGraphs


import Base: convert, size, eltype, ndims, ==, *, length

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
    spectral_distance,
    eigs

function eigs(A; kwargs...)
    schr =partialschur(A; kwargs...)
    vals, vectors = partialeigen(schr[1])
    reved = (kwargs[:which] == LR() || kwargs[:which] == LM())
    k = get(kwargs, :nev, length(vals))
    k = min(k, length(vals))
    perm = 1:k
    if vals[1] isa(Real)
        perm = sortperm(vals, rev=reved)
        perm = perm[1:k]
    end
    λ = vals[perm]
    Q = vectors[:, perm]
    return λ, Q
end

include("./graphmatrices.jl")
include("./spectral.jl")
include("./nonbacktracking.jl")

print(eigs)

end

