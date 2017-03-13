@testset "Pagerank" begin
    @test pagerank(g5)[3] ≈ 0.318 atol=0.001
    @test_throws ErrorException pagerank(g5, 2)
    @test_throws ErrorException pagerank(g5, 0.85, 2)
end
