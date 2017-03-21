@testset "Euclidean graphs" begin
    N = 10
    d = 2
    g, weights, points = @inferred(euclidean_graph(N, d))
    @test nv(g) == N
    @test ne(g) == N*(N-1) ÷ 2
    @test (d,N) == size(points)
    @test maximum(x->x[2], weights) <= sqrt(d)
    @test minimum(x->x[2], weights) >= 0
    @test maximum(points) <= 1
    @test minimum(points) >= 0.

    g, weights, points = @inferred(euclidean_graph(N, d, bc=:periodic))
    @test maximum(x->x[2], weights) <= sqrt(d/2)
    @test minimum(x->x[2], weights) >= 0.
    @test maximum(points) <= 1
    @test minimum(points) >= 0.


    @test_throws ErrorException euclidean_graph(points, L=0.01,  bc=:periodic)
    @test_throws ErrorException euclidean_graph(points, bc=:ciao)
end
