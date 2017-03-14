@testset "Pagerank" begin
    g5 = DiGraph(4)
    add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
    @test_approx_eq_eps(pagerank(g5)[3], 0.318, 0.001)
    @test_throws ErrorException pagerank(g5, 2)
    @test_throws ErrorException pagerank(g5, 0.85, 2)
end
