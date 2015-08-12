module TestLightGraphs
_HAVE_GRAPHMX = 
try 
    using GraphMatrices
    using FactCheck
    true
catch
    false
end

if _HAVE_GRAPHMX
using LightGraphs
using GraphMatrices
using FactCheck

function symmetrize(g::Graph, s::Symbol)
    return g
end
function symmetrize(g::DiGraph, s::Symbol)
    return Graph(g)
end

import GraphMatrices.CombinatorialAdjacency

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
    @fact adjmat.D --> vec(sum(mat, 1))
    @fact adjmat.A --> mat
    @fact convert(SparseMatrix{Float64}, adjmat) --> sparse(mat)
    @fact convert(SparseMatrix{Float64}, stochmat) --> truthy
    @fact convert(SparseMatrix{Float64}, adjhat) --> truthy
    @fact convert(SparseMatrix{Float64}, avgmat) --> truthy
    @fact prescalefactor(adjhat) --> postscalefactor(adjhat)
    @fact postscalefactor(stochmat) --> prescalefactor(avgmat)
    @fact prescalefactor(adjhat) --> postscalefactor(adjhat)
    @fact prescalefactor(avgmat) --> Noop()
end

function test_laplacian(mat)
    lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
    @fact lapl --> truthy
    #constructors that work.
    @fact adjacency(lapl).A --> mat
    @fact StochasticAdjacency(adjacency(lapl)) --> truthy
    @fact NormalizedAdjacency(adjacency(lapl))--> truthy
    @fact AveragingAdjacency(adjacency(lapl))--> truthy
    if VERSION >= v"0.4"
        @fact convert(Adjacency, lapl)--> truthy
        @fact convert(SparseMatrix{Float64}, lapl) --> truthy
    else
        @fact adjacency(lapl) --> truthy
        @fact sparse(lapl) --> truthy
    end

    adjmat, stochmat, adjhat, avgmat = constructors(mat)
    @fact adjacency(lapl) --> subtypepredicate(CombinatorialAdjacency)
    stochlapl = StochasticLaplacian(StochasticAdjacency{Float64}(adjmat))
    @fact adjacency(stochlapl) --> subtypepredicate(StochasticAdjacency)
    averaginglapl = AveragingLaplacian(AveragingAdjacency{Float64}(adjmat))
    @fact adjacency(averaginglapl) --> subtypepredicate(AveragingAdjacency)
    
    normalizedlapl = NormalizedLaplacian(NormalizedAdjacency{Float64}(adjmat))
    @fact adjacency(normalizedlapl) --> subtypepredicate(NormalizedAdjacency)
    @fact adjacency(normalizedlapl) --> isnot(subtypepredicate(CombinatorialAdjacency))

    #constructors that fail.
    @fact_throws CombinatorialAdjacency(lapl)
    @fact_throws StochasticLaplacian(lapl)# --> truthy
    @fact_throws NormalizedLaplacian(lapl)# --> truthy
    @fact_throws AveragingLaplacian(lapl)#  --> truthy
    @fact_throws convert(CombinatorialAdjacency, lapl) # --> truthy
    L = convert(SparseMatrix{Float64}, lapl)
    @fact sum(abs(sum(L,1))) --> 0
end

function test_accessors(mat, n)
    adjmat, stochmat, adjhat, avgmat = constructors(mat)
    dv = degrees(adjmat)
    @fact degrees(StochasticLaplacian(stochmat)) --> dv
    @fact degrees(NormalizedLaplacian(adjhat)) --> dv
    @fact degrees(AveragingLaplacian(avgmat)) --> dv

    for m in (adjmat, stochmat, adjhat, avgmat)
        @fact degrees(m) --> dv
        @fact eltype(m) --> eltype(m.A)
        @fact size(m) --> (n,n)
        #@fact length(m) --> length(adjmat.A)
    end
end

function test_arithmetic(mat, n)
    adjmat, stochmat, adjhat, avgmat = constructors(mat)
	lapl = CombinatorialLaplacian(adjmat)
	onevec = ones(Float64, n)
	v = @show adjmat*ones(Float64, n)
	@fact sum(abs(adjmat*onevec)) --> not(0)
    @fact sum(abs(stochmat*onevec/sum(onevec))) --> roughly(1)
	@fact sum(abs(lapl*onevec)) --> 0
	g(a) = sum(abs(sum(sparse(a),1)))
	@fact g(lapl) --> 0
	@fact g(NormalizedLaplacian(adjhat)) --> not(roughly(0))
	@fact g(StochasticLaplacian(stochmat)) --> not(roughly(0))

	@fact eigs(adjmat, which=:LR)[1][1] --> greater_than(1.0)
	@fact eigs(stochmat, which=:LR)[1][1] --> roughly(1.0)
	@fact eigs(avgmat, which=:LR)[1][1] --> roughly(1.0)
	@fact eigs(lapl, which=:LR)[1][1] --> greater_than(2.0)
	@fact_throws eigs(lapl, which=:SM)[1][1] # --> greater_than(-0.0)
	lhat = NormalizedLaplacian(adjhat)
	@fact eigs(lhat, which=:LR)[1][1] --> less_than(2.0 + 1e-9)
end

function test_other(mat, n )
	adjmat = CombinatorialAdjacency(mat)
	lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
	@fact size(lapl, 1) --> n
	@fact size(lapl, 2) --> n
	@fact size(lapl, 3) --> 1
	
	@fact_throws symmetrize(StochasticAdjacency{Float64}(adjmat))
	@fact_throws symmetrize(AveragingAdjacency{Float64}(adjmat))
	@fact_throws symmetrize(NormalizedAdjacency(adjmat)).A # --> adjmat.A
	
    context("equality testing ") do
        @fact CombinatorialAdjacency(mat) --> CombinatorialAdjacency(mat)
        S = StochasticAdjacency(CombinatorialAdjacency(mat))
        @fact S.A --> S.A
        @fact sparse(S) --> not(S.A)
        @fact adjacency(S) --> S.A
        @fact NormalizedAdjacency(adjmat) --> not(adjmat)
        @fact StochasticLaplacian(S) --> not(adjmat)
        @fact_throws StochasticLaplacian(adjmat) # --> not(adjmat)
    end
end

function test_symmetry(mat,n)
	adjmat = CombinatorialAdjacency(mat)
	lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
	@fact size(lapl, 1) --> n
	@fact size(lapl, 2) --> n
	@fact size(lapl, 3) --> 1
	
	@fact_throws symmetrize(StochasticAdjacency{Float64}(adjmat))
	@fact_throws symmetrize(AveragingAdjacency{Float64}(adjmat))
	@fact_throws symmetrize(NormalizedAdjacency(adjmat)).A # --> adjmat.A
	@fact symmetrize(adjmat).A --> adjmat.A
end

facts("constructors") do
    g = PathGraph(10)
    Ag = CombinatorialAdjacency(g)
    Am = CombinatorialAdjacency(adjacency_matrix(g))
    @fact Ag --> truthy
end

facts("constructors") do
	n = 10
    mat = PathGraph(10)
	context("Adjacency") do
        test_adjacency(mat)
    end

	context("Laplacian") do
        test_laplacian(mat)
    end

	context("Accessors") do
        test_accessors(mat, n)
    end
end


facts("arithmetic") do
	n = 10
    mat = PathGraph(10)
    @fact eltype(mat) --> Float64
    @fact zero(eltype(mat)) --> 0.0
    adjmat = CombinatorialAdjacency(mat)
    @fact eltype(adjmat) --> Float64
    @fact zero(eltype(adjmat)) --> 0.0
    test_arithmetic(mat, n)
end

facts("other tests") do
    n = 10
    mat = PathGraph(10)
    test_other(mat, n)
end
end
end
