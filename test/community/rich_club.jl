
@testset "Rich club coefficient" begin
    @testset "Small graphs" for n = 5:10
        @test @inferred rich_club(star_graph(_n),1) ≈ 2 / _n
        @test @inferred rich_club(DiGraph(star_graph(_n)),1) ≈ 2 / _n
    end
    @testset "Directed ($seed)" for seed in [1, 2, 3], (n, ne) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(n, ne; is_directed=true, seed=seed)
        _r = rich_club(g,1)
        @test @inferred rich_club(g,1) > 0.
    end
    @testset "Undirected ($seed)" for seed in [1, 2, 3], (n, ne) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(n, ne; is_directed=false, seed=seed)
        _r = rich_club(g,1)
        @test @inferred rich_club(g,1) > 0.
    end
end
