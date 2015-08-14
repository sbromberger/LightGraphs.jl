@test adjacency_matrix(g3)[3,2] == 1
@test adjacency_matrix(g3)[2,4] == 0
@test laplacian_matrix(g3)[3,2] == -1
@test laplacian_matrix(g3)[1,3] == 0
@test laplacian_spectrum(g3)[5] == 3.6180339887498945
@test adjacency_spectrum(g3)[1] == -1.732050807568878
@test laplacian_spectrum(g5)[3] == laplacian_spectrum(g5,:both)[3] == 3.0
@test laplacian_spectrum(g5,:in)[3] == 1.0
@test laplacian_spectrum(g5,:out)[3] == 1.0

@test_approx_eq_eps(adjacency_spectrum(g5)[3],0.311, 0.001)

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
    @test_approx_eq_eps minimum(evals) 0 1e-13
end



# GraphMatrices integration tests
if LightGraphs._HAVE_GRAPHMX
    println("*** Running GraphMatrices tests")
    mat = PathGraph(10)
    onevec = ones(Float64, 10)
    adjmat = CombinatorialAdjacency(mat)
    @test eltype(mat) == Float64
    @test zero(eltype(mat)) == 0.0
    @test eltype(adjmat) == Float64
    @test zero(eltype(adjmat)) == 0.0
    @test sum(abs(adjmat*onevec)) != 0
    lapl = GraphMatrices.CombinatorialLaplacian(adjmat)
    @test_approx_eq_eps(eigs(lapl, which=:LR)[1][1], 3.902, 0.001)
    println("*** Finished GraphMatrices tests")
else
    println("*** GraphMatrices not found - skipping tests")
end
