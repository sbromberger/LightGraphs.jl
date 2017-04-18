@testset "Pagerank" begin
    g5 = DiGraph(4)
    add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
    for g in testdigraphs(g5)
      @test @inferred(pagerank(g))[3] ≈ 0.318 atol=0.001
      @test_throws ErrorException pagerank(g, 2)
      @test_throws ErrorException pagerank(g, 0.85, 2)
    end
end
