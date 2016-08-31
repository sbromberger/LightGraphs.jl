@test adjacency_matrix(g3)[3,2] == 1
@test adjacency_matrix(g3)[2,4] == 0
@test laplacian_matrix(g3)[3,2] == -1
@test laplacian_matrix(g3)[1,3] == 0
@test laplacian_spectrum(g3)[5] == 3.6180339887498945
@test adjacency_spectrum(g3)[1] == -1.732050807568878
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

v = ones(Float64, ne(g10))
z = zeros(Float64, nv(g10))
n10 = Nonbacktracking(g10)
LightGraphs.contract!(z, n10, v)

zprime = contract(n10, v)
@test z == zprime
@test z == 9*ones(Float64, nv(g10))

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

# spectral distance checks
triangle = random_regular_graph(3, 2)
quadrangle = random_regular_graph(4, 2)
pentagon = random_regular_graph(5, 2)
for polygon in [triangle, quadrangle, pentagon]
  @test isapprox(spectral_distance(polygon, polygon), 0, atol=1e-8)
  @test isapprox(spectral_distance(polygon, polygon, 1), 0, atol=1e-8)
end
@test spectral_distance(triangle, quadrangle) < spectral_distance(triangle, pentagon)
