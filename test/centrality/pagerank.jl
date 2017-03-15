@testset "Pagerank" begin
    g5 = DiGraph(4)
    add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
    for g in (g5, DiGraph{UInt8}(g5), DiGraph{Int16}(g5))
      @test_approx_eq_eps(pagerank(g)[3], 0.318, 0.001)
      @test_throws ErrorException pagerank(g, 2)
      @test_throws ErrorException pagerank(g, 0.85, 2)
    end
end
