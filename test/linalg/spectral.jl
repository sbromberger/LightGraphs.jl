import Base: full

@testset "Spectral" begin
	@test adjacency_matrix(g3)[3,2] == 1
	@test adjacency_matrix(g3)[2,4] == 0
	@test laplacian_matrix(g3)[3,2] == -1
	@test laplacian_matrix(g3)[1,3] == 0
	@test laplacian_spectrum(g3)[5] == 3.6180339887498945
	@test adjacency_spectrum(g3)[1] == -1.732050807568878

	g5 = DiGraph(4)
	add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
	@test laplacian_spectrum(g5)[3] == laplacian_spectrum(g5,:both)[3] == 3.0
	@test laplacian_spectrum(g5,:in)[3] == 1.0
	@test laplacian_spectrum(g5,:out)[3] == 1.0

	# check adjacency matrices with self loops
	g = copy(g3)
	add_edge!(g,1,1)
	@test adjacency_matrix(g)[1,1] == 2

	g10 = CompleteGraph(10)
	B, em = non_backtracking_matrix(g10)
	@test length(em) == 2*ne(g10)
	@test size(B) == (2*ne(g10),2*ne(g10))
	for i=1:10
    	@test sum(B[:,i]) == 8
	    @test sum(B[i,:]) == 8
	end
	@test !issymmetric(B)

	v = ones(Float64, ne(g10))
	z = zeros(Float64, nv(g10))
	n10 = Nonbacktracking(g10)
	@test size(n10) == (2*ne(g10), 2*ne(g10))
	@test eltype(n10) == Float64
	@test !issymmetric(n10)

	LightGraphs.contract!(z, n10, v)

	zprime = contract(n10, v)
	@test z == zprime
	@test z == 9 * ones(Float64, nv(g10))

	@test (adjacency_spectrum(g5))[3] ≈ 0.311 atol=0.001

	@test adjacency_matrix(g3) ==
	    adjacency_matrix(g3, :out) ==
	    adjacency_matrix(g3, :in) ==
	    adjacency_matrix(g3, :both)

	@test_throws ErrorException adjacency_matrix(g3, :purple)

	#that call signature works
	inmat   = adjacency_matrix(g5, :in, Int)
	outmat  = adjacency_matrix(g5, :out, Int)
	bothmat = adjacency_matrix(g5, :both, Int)

	#relations that should be true
	@test inmat' == outmat
	@test all((bothmat - outmat) .>= 0)
	@test all((bothmat - inmat)  .>= 0)

	#check properties of the undirected laplacian carry over.
	for dir in [:in, :out, :both]
    	amat = adjacency_matrix(g5, dir, Float64)
	    lmat = laplacian_matrix(g5, dir, Float64)
	    @test isa(amat, SparseMatrixCSC{Float64, Int64})
	    @test isa(lmat, SparseMatrixCSC{Float64, Int64})
	    evals = eigvals(full(lmat))
	    @test all(evals .>= -1e-15) # positive semidefinite
	    @test (minimum(evals)) ≈ 0 atol=1e-13
	end


	# testing incidence_matrix, first directed graph
	@test size(incidence_matrix(g4)) == (5,4)
	@test incidence_matrix(g4)[1,1] == -1
	@test incidence_matrix(g4)[2,1] == 1
	@test incidence_matrix(g4)[3,1] == 0
	# now undirected graph
	@test size(incidence_matrix(g3)) == (5,4)
	@test incidence_matrix(g3)[1,1] == 1
	@test incidence_matrix(g3)[2,1] == 1
	@test incidence_matrix(g3)[3,1] == 0

	# undirected graph with orientation
	@test size(incidence_matrix(g3; oriented=true)) == (5,4)
	@test incidence_matrix(g3; oriented=true)[1,1] == -1
	@test incidence_matrix(g3; oriented=true)[2,1] == 1
	@test incidence_matrix(g3; oriented=true)[3,1] == 0

	# TESTS FOR Nonbacktracking operator.

	n = 10; k = 5
	pg = CompleteGraph(n)
	# ϕ1 = nonbacktrack_embedding(pg, k)'

	nbt = Nonbacktracking(pg)
	B, emap = non_backtracking_matrix(pg)
	Bs = sparse(nbt)
	@test sparse(B) == Bs
	@test eigs(nbt, nev=1)[1] ≈ eigs(B, nev=1)[1] atol=1e-5

	# check that matvec works
	x = ones(Float64, nbt.m)
	y = nbt * x
	z = B * x
	@test norm(y-z) < 1e-8

	#check that matmat works and full(nbt) == B
	@test norm(nbt*eye(nbt.m) - B) < 1e-8

	#check that matmat works and full(nbt) == B
	@test norm(nbt*eye(nbt.m) - B) < 1e-8

	#check that we can use the implicit matvec in nonbacktrack_embedding
	@test size(y) == size(x)

	B₁ = Nonbacktracking(g10)

	# just so that we can assert equality of matrices
	full(nbt::Nonbacktracking) = full(sparse(nbt))

	@test full(B₁) == full(B)
	@test sum(sparse(B₁) - sparse(B)) == 0

	for i in 1:100
    	x = randn(size(B,2))
	    y  = B * x
    	y₁ = B₁ * x
	    @test norm(y - y₁) < 1e-6
	end


	@test  B₁ * ones(size(B₁)[2]) == B * ones(size(B)[2])
	@test  B₁ * ones(size(B₁)[2]) == B * ones(size(B)[2])
	@test size(B₁) == size(B)
	evd = eigs(B)
	evd1 = eigs(B₁)
	# @show λ11 = evd1[1]
	# @show λ1 = evd[1]
	evecs  = evd[2]
	evecs1 = evd1[2]
	# @show norm(evecs'*λ1*evecs - evecs1'*λ1*evecs)
	# @test norm(evecs'*evecs - I) < 1e-6
	# @test norm(evecs1'*evecs1 - I) < 1e-6
	# @show evecs[1:5, 1:5]
	# @show evecs1[1:5, 1:5]
	# @show norm(evecs'*evecs1 - I)

	@test_skip norm(λ11 - λ1) ≈ 0.0 atol=1e-4
	@test !issymmetric(B₁)
	@test eltype(B₁) == Float64
	# END tests for Nonbacktracking

# spectral distance checks
	for n=3:10
	  polygon = random_regular_graph(n, 2)
	  @test isapprox(spectral_distance(polygon, polygon), 0, atol=1e-8)
	  @test isapprox(spectral_distance(polygon, polygon, 1), 0, atol=1e-8)
	end
end # testset
