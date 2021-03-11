using Random, Statistics

@testset "Assortativity" begin
    # Test definition of assortativity as Pearson correlation coefficient
    # between excess of degrees
    @testset "Small graphs" for n = 5:10
        @test @inferred assortativity(wheel_graph(n)) ≈ -1/3
    end
    @testset "Directed ($seed)" for seed in [1, 2, 3], (n, ne) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(n, ne; is_directed=true, seed=seed)
        assort = assortativity(g)
        x = [outdegree(g, src(d))-1 for d in edges(g)]
        y = [indegree(g, dst(d))-1 for d in edges(g)]
        @test @inferred assort ≈ cor(x, y)
    end
    @testset "Undirected ($seed)" for seed in [1, 2, 3], (n, ne) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(n, ne; is_directed=false, seed=seed)
        assort = assortativity(g)
        x = [outdegree(g, src(d))-1 for d in edges(g)]
        y = [indegree(g, dst(d))-1 for d in edges(g)]
        @test @inferred assort ≈ cor([x;y], [y;x])
    end

    # Test definition of assortativity as Pearson correlation coefficient
    # between some scalar attributes characterising each vertex
    @testset "Small graphs with attributes" for n = 5:2:11
        g = grid([1,n])
        attributes = [(-1.)^v for v in vertices(g)]
        @test @inferred assortativity(g,attributes) ≈ -1.
    end
    @testset "Directed ($seed) with attributes" for seed in [1, 2, 3], (_n, _ne) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(_n, _ne; is_directed=true, seed=seed)
        attributes = randn(_n)
        assort = assortativity(g,attributes)
        x = [attributes[src(d)] for d in edges(g)]
        y = [attributes[dst(d)]  for d in edges(g)]
        @test @inferred assort ≈ cor(x, y)
    end
    @testset "Undirected ($seed) with attributes" for seed in [1, 2, 3], (_n, _ne) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(_n, _ne; is_directed=false, seed=seed)
        attributes = randn(_n)
        assort = assortativity(g,attributes)
        x = [attributes[src(d)] for d in edges(g)]
        y = [attributes[dst(d)]  for d in edges(g)]
        @test @inferred assort ≈ cor([x;y], [y;x])
    end
end
