@testset "Euclidean graphs" begin
    N = 10
    d = 2
    g, weights, points = @inferred(euclidean_graph(N, d))
    @test nv(g) == N
    @test ne(g) == N * (N - 1) ÷ 2
    @test (d, N) == size(points)
    @test maximum(x -> x[2], weights) <= sqrt(d)
    @test minimum(x -> x[2], weights) >= 0
    @test maximum(points) <= 1
    @test minimum(points) >= 0.0

    g, weights, points = @inferred(euclidean_graph(N, d, bc = :periodic))
    @test maximum(x -> x[2], weights) <= sqrt(d / 2)
    @test minimum(x -> x[2], weights) >= 0.0
    @test maximum(points) <= 1
    @test minimum(points) >= 0.0

    @test_throws DomainError euclidean_graph(points, L = 0.01, bc = :periodic)
    @test_throws ArgumentError euclidean_graph(points, bc = :badbc)

    # In our algorithm we ensure, that the resulting graph has the same
    # number of vertices as we have points. For this we have a special case,
    # where we have to insert vertices if the vertices with the highest indices are
    # isolated. This test ensures that this case is covered.
    @testset "Euclidean graph with vertex of highest index isolated" begin
        point1 = [1.0, 0.0, 0.0]
        point2 = [0.0, 1.0, 0.0]
        point3 = [0.0, 0.0, 100.0]
        matrix = hcat(point1, point2, point3)
        g, _ = euclidean_graph(matrix, cutoff = 5.0)
        @test has_edge(g, 1, 2) && ne(g) == 1
        @test nv(g) == 3
    end
end
