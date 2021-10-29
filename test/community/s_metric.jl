using Random, Statistics

@testset "S-metric" begin
    @testset "Directed ($seed)" for seed in [1, 2, 3], (_n, _ne) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(_n, _ne; is_directed=true, seed=seed)
        sm = s_metric(g, norm=false)
        sm2 = sum([outdegree(g, src(d)) * indegree(g, dst(d)) for d in edges(g)])
        @test @inferred sm ≈ sm2
        sm = s_metric(g, norm=true)
        sm2 /= sum(degree(g).^3)/2
        @test @inferred sm ≈ sm2
    end
    @testset "Undirected ($seed)" for seed in [1, 2, 3], (_n, _ne) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(_n, _ne; is_directed=false, seed=seed)
        sm = s_metric(g, norm=false)
        sm2 = sum([degree(g, src(d)) * degree(g, dst(d)) for d in edges(g)])
        @test @inferred sm ≈ sm2
        sm = s_metric(g, norm=true)
        sm2 /= sum(degree(g).^3)/2
        @test @inferred sm ≈ sm2
    end
end
