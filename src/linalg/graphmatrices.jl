__precompile__(true)


import Base: convert, sparse, size, diag, eltype, ndims, ==, *, .*, issymmetric, A_mul_B!, length, Diagonal
export  convert,
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
		postscalefactor



const SparseMatrix{T} = SparseMatrixCSC{T,Int64}

"""
	GraphMatrix{T}

An abstract type to allow opertions on any type of graph matrix
"""
abstract type GraphMatrix{T} end


"""
	Adjacency{T}

The core Adjacency matrix structure. Keeps the vertex degrees around.
Subtypes are used to represent the different normalizations of the adjacency matrix.
Laplacian and its subtypes are used for the different Laplacian matrices.

Adjacency(lapl::Laplacian) provides a generic function for getting the
adjacency matrix of a Laplacian matrix. If your subtype of Laplacian does not provide
an field A for the Adjacency instance, then attach another method to this function to provide
an Adjacency{T} representation of the Laplacian. The Adjacency matrix here
is the final subtype that corresponds to this type of Laplacian
"""
abstract type Adjacency{T} <: GraphMatrix{T} end
abstract type Laplacian{T} <: GraphMatrix{T} end

"""
	CombinatorialAdjacency{T,S,V}

The standard adjacency matrix.
"""
struct CombinatorialAdjacency{T,S,V} <: Adjacency{T}
	A::S
	D::V
end

function CombinatorialAdjacency(A::SparseMatrix{T}) where T
	D = vec(sum(A,1))
	return CombinatorialAdjacency{T,SparseMatrix{T},typeof(D)}(A,D)
end


@doc_str """
	NormalizedAdjacency{T}

The normalized adjacency matrix is ``\\hat{A} = D^{-1/2} A D^{-1/2}``.
If A is symmetric, then the normalized adjacency is also symmetric
with real eigenvalues bounded by [-1, 1].
"""
struct NormalizedAdjacency{T} <: Adjacency{T}
	A::CombinatorialAdjacency{T}
	scalefactor::Vector{T}
end
function NormalizedAdjacency(adjmat::CombinatorialAdjacency)
	sf = adjmat.D.^(-1/2)
	return NormalizedAdjacency(adjmat, sf)
end

"""
	StochasticAdjacency{T}

A transition matrix for the random walk.
"""
struct StochasticAdjacency{T} <: Adjacency{T}
	A::CombinatorialAdjacency{T}
	scalefactor::Vector{T}

end
function StochasticAdjacency(adjmat::CombinatorialAdjacency)
	sf = adjmat.D.^(-1)
	return StochasticAdjacency(adjmat, sf)
end

"""
	AveragingAdjacency{T}

The matrix whose action is to average over each neighborhood.
"""
struct AveragingAdjacency{T} <: Adjacency{T}
	A::CombinatorialAdjacency{T}
	scalefactor::Vector{T}
end
function AveragingAdjacency(adjmat::CombinatorialAdjacency)
	sf = adjmat.D.^(-1)
	return AveragingAdjacency(adjmat, sf)
end

perron(adjmat::NormalizedAdjacency) = sqrt.(adjmat.A.D)/norm(sqrt.(adjmat.A.D))

struct PunchedAdjacency{T} <: Adjacency{T}
	A::NormalizedAdjacency{T}
	perron::Vector{T}
end
function PunchedAdjacency(adjmat::CombinatorialAdjacency)
            perron=sqrt.(adjmat.D)/norm(sqrt.(adjmat.D))
            return PunchedAdjacency(NormalizedAdjacency(adjmat), perron)
end

perron(m::PunchedAdjacency) = m.perron

"""
	Noop

A type that represents no action.

### Implementation Notes
- The purpose of `Noop` is to help write more general code for the
different scaled GraphMatrix types.
"""
struct Noop end

Base.broadcast(::typeof(*), ::Noop, x) = x

Diagonal(::Noop) = Noop()


==(g::GraphMatrix, h::GraphMatrix) = typeof(g) == typeof(h) && (g.A == h.A)

postscalefactor(::Adjacency)= Noop()

postscalefactor(adjmat::NormalizedAdjacency) = adjmat.scalefactor

postscalefactor(adjmat::AveragingAdjacency) = adjmat.scalefactor

prescalefactor(::Adjacency) = Noop()

prescalefactor(adjmat::NormalizedAdjacency) = adjmat.scalefactor

prescalefactor(adjmat::StochasticAdjacency) = adjmat.scalefactor


struct CombinatorialLaplacian{T} <: Laplacian{T}
	A::CombinatorialAdjacency{T}
end

@doc_str """
	NormalizedLaplacian{T}

The normalized Laplacian is ``\\hat{L} = I - D^{-1/2} A D^{-1/2}``.
If A is symmetric, then the normalized Laplacian is also symmetric
with positive eigenvalues bounded by 2.
"""
struct NormalizedLaplacian{T} <: Laplacian{T}
	A::NormalizedAdjacency{T}
end

"""
	StochasticLaplacian{T}

Laplacian version of the StochasticAdjacency matrix.
"""
struct StochasticLaplacian{T} <: Laplacian{T}
	A::StochasticAdjacency{T}
end

"""
	AveragingLaplacian{T}

Laplacian version of the AveragingAdjacency matrix.
"""
struct AveragingLaplacian{T} <: Laplacian{T}
	A::AveragingAdjacency{T}
end

arrayfunctions = (:eltype, :length, :ndims, :size, :strides, :issymmetric)
for f in arrayfunctions
	@eval $f(a::GraphMatrix) = $f(a.A)
end

size(a::GraphMatrix, i::Integer) = size(a.A, i)
issymmetric(::StochasticAdjacency) = false
issymmetric(::AveragingAdjacency) = false

"""
	degrees(adjmat)

Retun the degrees of a graph represented by the CombinatorialAdjacency `adjmat`.
"""
degrees(adjmat::CombinatorialAdjacency) = adjmat.D

"""
	degrees(graphmx)

Return the degrees of a graph represented by the graph matrix `graphmx`.
"""
degrees(mat::GraphMatrix) = degrees(adjacency(mat))

adjacency(lapl::Laplacian) = lapl.A
adjacency(lapl::GraphMatrix) = lapl.A



convert(::Type{CombinatorialAdjacency}, adjmat::Adjacency) = adjmat.A
convert(::Type{CombinatorialAdjacency}, adjmat::CombinatorialAdjacency) = adjmat


function sparse(lapl::M) where M<:Laplacian
	adjmat = adjacency(lapl)
	A = sparse(adjmat)
	L = spdiagm(diag(lapl)) - A
	return L
end

function sparse(adjmat::Adjacency)
    A = sparse(adjmat.A)
    return Diagonal(prescalefactor(adjmat)) * (A * Diagonal(postscalefactor(adjmat)))
end

function convert(::Type{SparseMatrix{T}}, adjmat::Adjacency{T}) where T
    A = sparse(adjmat.A)
    return Diagonal(prescalefactor(adjmat)) * (A * Diagonal(postscalefactor(adjmat)))
end


function convert(::Type{SparseMatrix{T}}, lapl::Laplacian{T}) where T
	adjmat = adjacency(lapl)
	A = convert(SparseMatrix{T}, adjmat)
	L = spdiagm(diag(lapl)) - A
	return L
end

diag(lapl::CombinatorialLaplacian) = lapl.A.D
diag(lapl::Laplacian) = ones(size(lapl)[2])

*(x::AbstractArray, ::Noop) = x
*(::Noop, x) = x
*{T<:Number}(adjmat::Adjacency{T}, x::AbstractVector{T}) =
	postscalefactor(adjmat) .* (adjmat.A * (prescalefactor(adjmat) .* x))


*(adjmat::CombinatorialAdjacency{T}, x::AbstractVector{T}) where T<:Number=
	adjmat.A * x

*(lapl::Laplacian{T}, x::AbstractVector{T}) where T<:Number=
	(diag(lapl) .* x) - (adjacency(lapl)*x)


function *(adjmat::PunchedAdjacency{T}, x::AbstractVector{T}) where T<:Number
    y=adjmat.A*x
    return y - dot(adjmat.perron, y)*adjmat.perron
end

function A_mul_B!(Y, A::Adjacency, B)
    # we need to do 3 matrix products
    # Y and B can't overlap in any one call to A_mul_B!
    # The last call to A_mul_B! must be (Y, postscalefactor, tmp)
    # so we need to write to tmp in the second step  must be (tmp, A.A, Y)
    # and the first step (Y, prescalefactor, B)
    tmp1 = Diagonal(prescalefactor(A)) * B
    tmp = similar(Y)
    A_mul_B!(tmp, A.A, tmp1)
    return A_mul_B!(Y, Diagonal(postscalefactor(A)), tmp)
end

A_mul_B!(Y, A::CombinatorialAdjacency, B) = A_mul_B!(Y, A.A, B)

# You can compute the StochasticAdjacency product without allocating a similar of Y.
# This is true for all Adjacency where the postscalefactor is a Noop
# at time of writing this is just StochasticAdjacency and CombinatorialAdjacency
function A_mul_B!(Y, A::StochasticAdjacency, B)
    tmp = Diagonal(prescalefactor(A)) * B
    A_mul_B!(Y, A.A, tmp)
    return Y
end

function A_mul_B!(Y, adjmat::PunchedAdjacency, x)
    y = adjmat.A*x
    Y[:] = y - dot(adjmat.perron, y)*adjmat.perron
    return Y
end

function A_mul_B!(Y, lapl::Laplacian, B)
    A_mul_B!(Y, lapl.A, B)
	  z = diag(lapl) .* B
    Y[:] = z - Y[:]
    return Y
end


"""
	symmetrize(A::SparseMatrix, which=:or)

Returns a symmetric version of graph (represented by sparse matrix `A`) as a sparse matrix.
`which` may be one of `:triu`, `:tril`, `:sum`, or `:or`. Use `:sum` for weighted graphs.
"""
function symmetrize(A::SparseMatrix, which=:or)
	  if which==:or
	      M = A + A'
	      M.nzval[M.nzval .== 2] = 1
        return M
    end
    T = A
	  if which==:triu
		    T = triu(A)
	  elseif which==:tril
		    T = tril(A)
    elseif which==:sum
		    T = A
    else
        error("$which is not a supported method of symmetrizing a matrix")
    end
		M = T + T'
	  return M
end

"""
	symmetrize(adjmat, which=:or)

Returns a symmetric version of graph (represented by `CombinatorialAdjacency` `adjmat`)
as a `CombinatorialAdjacency`. `which` may be one of `:triu`, `:tril`, `:sum`, or `:or`.
Use `:sum` for weighted graphs.

### Implementation Notes
Only works on Adjacency because the normalizations don't commute with symmetrization.
"""
symmetrize(adjmat::CombinatorialAdjacency, which=:or) =
	CombinatorialAdjacency(symmetrize(adjmat.A, which))


# per #564
@deprecate A_mul_B!(Y, A::Noop, B) None
@deprecate convert(::Type{Adjacency}, lapl::Laplacian) None
@deprecate convert(::Type{SparseMatrix}, adjmat::CombinatorialAdjacency) sparse(adjmat)



"""
	LinAlg

A package for using the type system to check types of graph matrices
"""
LinAlg
