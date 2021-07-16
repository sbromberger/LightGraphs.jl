@testset "Wilson" begin
    g = SimpleGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 1, 4)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)

    N = 2*10^4
    diag_edge = Edge(1, 3)
    tol = 0.01

    # checking spanning tree count
    minor = Matrix(view(laplacian_matrix(g), 2:4, 2:4))
    @test Int(det(minor)) == 8

    # Testing Wilson's algorithm on an unweighted graphs
    diag_count = 0
    for ii = 1:N
        st = @inferred(wilson_rst(g, seed=5124154 + 312*ii))
        diag_count += Int(diag_edge in st)
    end
    @test abs(0.5 - diag_count/N) < tol

    rng = MersenneTwister(123411223)
    diag_count = 0
    for ii = 1:N
        st = @inferred(wilson_rst(g, rng=rng))
        diag_count += Int(diag_edge in st)
    end
    @test abs(0.5 - diag_count/N) < tol

    # Testing Wilson's algorithm on a weighted graph
    distmx = ones(Float64, 4, 4)
    distmx[1,3] = 0.5
    distmx[3,1] = 0.5

    diag_count = 0
    N = 10^5
    for ii = 1:N
        st = @inferred(wilson_rst(g, distmx, seed=1509812+192*ii))
        diag_count += Int(Edge(1,3) in st)
    end
    @test abs(1/3 - diag_count/N) < tol
end
