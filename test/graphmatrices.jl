module TestLightGraphs
_HAVE_GRAPHMX = 
try 
    using GraphMatrices
    true
catch
    false
end

using Base.Test
if _HAVE_GRAPHMX
using LightGraphs
using GraphMatrices

function symmetrize(g::Graph, s::Symbol)
    return g
end
function symmetrize(g::DiGraph, s::Symbol)
    return Graph(g)
end

import GraphMatrices.CombinatorialAdjacency
import GraphMatrices.SparseMatrix

function CombinatorialAdjacency(A)
    D = float(indegree(A, vertices(A)))
    return CombinatorialAdjacency{Float64, typeof(A), typeof(D)}(A,D)
end

function subtypepredicate(T)
	pred(x) = issubtype(typeof(x), T)
	return pred
end

function isnot(f::Function)
	return g(x) = !f(x)
end

function constructors(mat)
    adjmat = CombinatorialAdjacency(mat)
    stochmat = StochasticAdjacency(adjmat)
    adjhat = NormalizedAdjacency(adjmat)
    avgmat = AveragingAdjacency(adjmat)
    return adjmat, stochmat, adjhat, avgmat
end

function test_adjacency(mat)
    adjmat, stochmat, adjhat, avgmat = constructors(mat)
    @test adjmat.D == vec(sum(mat, 1))
    @test adjmat.A == mat
    @test convert(SparseMatrix{Float64}, adjmat) == sparse(mat)
    @test convert(SparseMatrix{Float64}, stochmat) != None
    @test convert(SparseMatrix{Float64}, adjhat) != None
    @test convert(SparseMatrix{Float64}, avgmat) != None
    @test prescalefactor(adjhat) == postscalefactor(adjhat)
    @test postscalefactor(stochmat) == prescalefactor(avgmat)
    @test prescalefactor(adjhat) == postscalefactor(adjhat)
    @test prescalefactor(avgmat) == Noop()
end

function test_laplacian(mat)
    lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
    @test lapl != None
    #constructors that work.
    @test adjacency(lapl).A == mat
    @test StochasticAdjacency(adjacency(lapl)) != None
    @test NormalizedAdjacency(adjacency(lapl))!= None
    @test AveragingAdjacency(adjacency(lapl))!= None
    if VERSION >= v"0.4"
        @test convert(Adjacency, lapl)!= None
        @test convert(SparseMatrix{Float64}, lapl) != None
    else
        @test adjacency(lapl) != None
        @test sparse(lapl) != None
    end

    adjmat, stochmat, adjhat, avgmat = constructors(mat)
    @test isa(adjacency(lapl),CombinatorialAdjacency)
    stochlapl = StochasticLaplacian(StochasticAdjacency{Float64}(adjmat))
    @test isa(adjacency(stochlapl), StochasticAdjacency)
    averaginglapl = AveragingLaplacian(AveragingAdjacency{Float64}(adjmat))
    @test isa(adjacency(averaginglapl),AveragingAdjacency)
    
    normalizedlapl = NormalizedLaplacian(NormalizedAdjacency{Float64}(adjmat))
    @test isa(adjacency(normalizedlapl), NormalizedAdjacency)
    @test !isa(adjacency(normalizedlapl), CombinatorialAdjacency)

    #constructors that fail.
    @test_throws MethodError CombinatorialAdjacency(lapl)
    @test_throws MethodError StochasticLaplacian(lapl)# != None
    @test_throws MethodError NormalizedLaplacian(lapl)# != None
    @test_throws MethodError AveragingLaplacian(lapl)#  != None
    @test_throws MethodError convert(CombinatorialAdjacency, lapl) # != None
    L = convert(SparseMatrix{Float64}, lapl)
    @test sum(abs(sum(L,1))) == 0
end

function test_accessors(mat, n)
    adjmat, stochmat, adjhat, avgmat = constructors(mat)
    dv = degrees(adjmat)
    @test degrees(StochasticLaplacian(stochmat)) == dv
    @test degrees(NormalizedLaplacian(adjhat)) == dv
    @test degrees(AveragingLaplacian(avgmat)) == dv

    for m in (adjmat, stochmat, adjhat, avgmat)
        @test degrees(m) == dv
        @test eltype(m) == eltype(m.A)
        @test size(m) == (n,n)
        #@test length(m) == length(adjmat.A)
    end
end

function test_arithmetic(mat, n)
    T_EPS_VAL=1e-10
    adjmat, stochmat, adjhat, avgmat = constructors(mat)
	lapl = CombinatorialLaplacian(adjmat)
	onevec = ones(Float64, n)
	v = @show adjmat*ones(Float64, n)
	@test sum(abs(adjmat*onevec)) != 0
    @test_approx_eq_eps sum(abs(stochmat*onevec/sum(onevec))) 1 T_EPS_VAL
	@test sum(abs(lapl*onevec)) == 0
	g(a) = sum(abs(sum(sparse(a),1)))
	@test g(lapl) == 0
	@test abs(g(NormalizedLaplacian(adjhat))) >= T_EPS_VAL
	@test abs(g(StochasticLaplacian(stochmat))) >= T_EPS_VAL

	@test eigs(adjmat, which=:LR)[1][1] > 1
	@test_approx_eq_eps eigs(stochmat, which=:LR)[1][1] 1.0 T_EPS_VAL
	@test_approx_eq_eps eigs(avgmat, which=:LR)[1][1]   1.0 T_EPS_VAL
	@test eigs(lapl, which=:LR)[1][1] > 2.0
	@test_throws MethodError eigs(lapl, which=:SM)[1][1] 
	lhat = NormalizedLaplacian(adjhat)
	@test eigs(lhat, which=:LR)[1][1] < 2 + T_EPS_VAL
end

function test_other(mat, n )
	adjmat = CombinatorialAdjacency(mat)
	lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
	@test size(lapl, 1) == n
	@test size(lapl, 2) == n
	@test size(lapl, 3) == 1
	
	@test_throws MethodError symmetrize(StochasticAdjacency{Float64}(adjmat))
	@test_throws MethodError symmetrize(AveragingAdjacency{Float64}(adjmat))
	@test_throws MethodError symmetrize(NormalizedAdjacency(adjmat)).A # == adjmat.A
	
    println("equality testing ")
    @test CombinatorialAdjacency(mat) == CombinatorialAdjacency(mat)
    S = StochasticAdjacency(CombinatorialAdjacency(mat))
    @test S.A == S.A
    @test sparse(S) != S.A
    @test adjacency(S) == S.A
    @test NormalizedAdjacency(adjmat) != adjmat
    @test StochasticLaplacian(S) != adjmat
    @test_throws MethodError StochasticLaplacian(adjmat) # != adjmat
end

function test_symmetry(mat,n)
	adjmat = CombinatorialAdjacency(mat)
	lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
	@test size(lapl, 1) == n
	@test size(lapl, 2) == n
	@test size(lapl, 3) == 1
	
	@test_throws MethodError symmetrize(StochasticAdjacency{Float64}(adjmat))
	@test_throws MethodError symmetrize(AveragingAdjacency{Float64}(adjmat))
	@test_throws MethodError symmetrize(NormalizedAdjacency(adjmat)).A # == adjmat.A
	@test symmetrize(adjmat).A == adjmat.A
end

println("constructors")
    g = PathGraph(10)
    Ag = CombinatorialAdjacency(g)
    Am = CombinatorialAdjacency(adjacency_matrix(g))
    @test Ag != None
end

println("constructors")
n = 10
mat = PathGraph(n)
println("Adjacency")
test_adjacency(mat)

println("Laplacian")
test_laplacian(mat)

println("Accessors")
test_accessors(mat, n)


println("Arithmetic")
n = 10
mat = PathGraph(10)
@test eltype(mat) == Float64
@test zero(eltype(mat)) == 0.0
adjmat = CombinatorialAdjacency(mat)
@test eltype(adjmat) == Float64
@test zero(eltype(adjmat)) == 0.0
test_arithmetic(mat, n)

println("other tests")
n = 10
mat = PathGraph(10)
test_other(mat, n)
end
