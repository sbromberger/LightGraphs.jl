module TestLinAlg
using LightGraphs.LinAlg
using Base.Test
import LightGraphs.LinAlg.SparseMatrix
import LightGraphs.LinAlg.perron


export test_adjacency, test_laplacian, test_accessors, test_arithmetic, test_other

function converttest(T::Type, var)
    @test typeof(convert(T, var)) == T
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
    converttest(SparseMatrix{Float64},stochmat)
    converttest(SparseMatrix{Float64},adjhat)
    converttest(SparseMatrix{Float64},avgmat)
    @test prescalefactor(adjhat) == postscalefactor(adjhat)
    @test postscalefactor(stochmat) == prescalefactor(avgmat)
    @test prescalefactor(adjhat) == postscalefactor(adjhat)
    @test prescalefactor(avgmat) == Noop()
end

function test_laplacian(mat)
    lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
    @test typeof(lapl) <: Laplacian
    #constructors that work.
    @test adjacency(lapl).A == mat
    adj = adjacency(lapl)
    @test typeof(StochasticAdjacency(adj)) <: StochasticAdjacency
    @test typeof(NormalizedAdjacency(adj)) <: NormalizedAdjacency
    @test typeof(AveragingAdjacency(adj)) <: AveragingAdjacency
    if VERSION >= v"0.4"
        @test typeof(adjacency(lapl)) <: CombinatorialAdjacency
        converttest(SparseMatrix{Float64},lapl)
    else
        @test adjacency(lapl) != nothing
        @test sparse(lapl)    != nothing
    end

    adjmat, stochmat, adjhat, avgmat = constructors(mat)
    @test typeof(adjacency(lapl))  <: CombinatorialAdjacency
    stochlapl = StochasticLaplacian(StochasticAdjacency{Float64}(adjmat))
    @test typeof(adjacency(stochlapl))  <: StochasticAdjacency
    averaginglapl = AveragingLaplacian(AveragingAdjacency{Float64}(adjmat))
    @test typeof(adjacency(averaginglapl))  <: AveragingAdjacency

    normalizedlapl = NormalizedLaplacian(NormalizedAdjacency{Float64}(adjmat))
    @test typeof(adjacency(normalizedlapl))  <: NormalizedAdjacency
    @test !( typeof(adjacency(normalizedlapl)) <: CombinatorialAdjacency)

    #constructors that fail.
    @test_throws MethodError CombinatorialAdjacency(lapl)
    @test_throws MethodError StochasticLaplacian(lapl)
    @test_throws MethodError NormalizedLaplacian(lapl)
    @test_throws MethodError AveragingLaplacian(lapl)
    @test_throws MethodError convert(CombinatorialAdjacency, lapl)
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
        #@fact length(m) --> length(adjmat.A)
    end
end

function test_arithmetic(mat, n)
    adjmat, stochmat, adjhat, avgmat = constructors(mat)
	lapl = CombinatorialLaplacian(adjmat)
	onevec = ones(Float64, n)
	v = @show adjmat*ones(Float64, n)
	@test sum(abs(adjmat*onevec)) > 0.0
  @test_approx_eq sum(abs(stochmat*onevec/sum(onevec))) 1.0
	@test sum(abs(lapl*onevec)) == 0
	g(a) = sum(abs(sum(sparse(a),1)))
	@test g(lapl) == 0
	@test g(NormalizedLaplacian(adjhat)) > 1e-13
	@test g(StochasticLaplacian(stochmat)) > 1e-13

	@test eigs(adjmat, which=:LR)[1][1] > 1.0
	@test_approx_eq eigs(stochmat, which=:LR)[1][1]  1.0
	@test_approx_eq eigs(avgmat, which=:LR)[1][1]  1.0
	@test eigs(lapl, which=:LR)[1][1] > 2.0
	@test_throws MethodError eigs(lapl, which=:SM)[1][1] # --> greater_than(-0.0)
	lhat = NormalizedLaplacian(adjhat)
	@test eigs(lhat, which=:LR)[1][1] < 2.0 + 1e-9
end

function test_other(mat, n )
	adjmat = CombinatorialAdjacency(mat)
	lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
	@test size(lapl, 1) == n
	@test size(lapl, 2) == n
	@test size(lapl, 3) == 1
	
	@test_throws MethodError symmetrize(StochasticAdjacency{Float64}(adjmat))
	@test_throws MethodError symmetrize(AveragingAdjacency{Float64}(adjmat))
	@test_throws MethodError symmetrize(NormalizedAdjacency(adjmat)).A # --> adjmat.A
	
    println("equality testing "); begin
        @test CombinatorialAdjacency(mat) == CombinatorialAdjacency(mat)
        S = StochasticAdjacency(CombinatorialAdjacency(mat))
        @test S.A == S.A
        @test sparse(S) != S.A
        @test adjacency(S) == S.A
        @test NormalizedAdjacency(adjmat) != adjmat
        @test StochasticLaplacian(S) != adjmat
        @test_throws MethodError StochasticLaplacian(adjmat) # --> not(adjmat)
    end
end

function test_symmetry(mat,n)
	adjmat = CombinatorialAdjacency(mat)
	lapl = CombinatorialLaplacian(CombinatorialAdjacency(mat))
	@test size(lapl, 1) == n
	@test size(lapl, 2) == n
	@test size(lapl, 3) == 1
	
	@test_throws MethodError symmetrize(StochasticAdjacency{Float64}(adjmat))
	@test_throws MethodError symmetrize(AveragingAdjacency{Float64}(adjmat))
	@test_throws MethodError symmetrize(NormalizedAdjacency(adjmat)).A # --> adjmat.A
	@test symmetrize(adjmat).A == adjmat.A
    # these tests are basically the code
	@test symmetrize(adjmat, :triu).A == triu(adjmat.A) + triu(adjmat.A)'
	@test symmetrize(adjmat, :tril).A == tril(adjmat.A) + tril(adjmat.A)'
	@test symmetrize(adjmat, :sum).A == adjmat.A + adjmat.A
end

function test_punchedmatrix(mat, n)
    adjmat = CombinatorialAdjacency(mat)
    ahatp  = PunchedAdjacency(adjmat)
    eval, evecs = eigs(ahatp, which=:LM)
    @test eval[1]-1  <= 0
    @test_approx_eq_eps dot(perron(ahatp), evecs[:,1]) 0.0 1e-8
end

println("constructors");begin
	n = 10
	mat = sparse(spones(sprand(n,n,0.3)))
	println("Adjacency");begin
        test_adjacency(mat)
    end

	println("Laplacian");begin
        test_laplacian(mat)
    end

	println("Accessors");begin
        test_accessors(mat, n)
    end
end


println("arithmetic");begin
	n = 10
	mat = symmetrize(sparse(spones(sprand(n,n,0.3))))
    test_arithmetic(mat, n)
end

println("other tests");begin
	n = 10
	mat = symmetrize(sparse(spones(sprand(n,n,0.3))))
	test_other(mat, n)
	test_symmetry(mat, n)
	test_punchedmatrix(mat, n)
end


@doc "Computes the stationary distribution of a random walk" ->
function stationarydistribution(R::StochasticAdjacency; kwargs...)
	er = eigs(R, nev=1, which=:LR; kwargs...)
	l1 = er[1][1]
	abs(l1 -1) < 1e-8 || error("failed to compute stationary distribution")
	p = real(er[2][:,1])
	if p[1] < 0
		for i in 1:length(p)
			p[i] = -p[i]
		end
	end
	return p
end

function stationarydistribution(A::CombinatorialAdjacency; kwargs...)
	R = StochasticAdjacency(A)
	stationarydistribution(R; kwargs...)
end

println("Random Walk Demo")
begin
	n = 100
	p = 16/n
	M = sprand(n,n, p)
	M.nzval[:] = 1.0
	A = CombinatorialAdjacency(M)
  sd = stationarydistribution(A; ncv=10)
	@test all(sd.>=0)
end
end
