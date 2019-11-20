@testset "Clustering" begin
    g10 = complete_graph(10)
    for g in testgraphs(g10)
        @test @inferred(local_clustering_coefficient(g, 1)) == 1.0
        @test @inferred(local_clustering_coefficient(g)) == ones(10)
        @test @inferred(global_clustering_coefficient(g)) == 1.0
        @test @inferred(local_clustering(g)) == (fill(36, 10), fill(36, 10))
        @test @inferred(triangles(g)) == fill(36, 10)
        @test @inferred(triangles(g, 1)) == 36
    end
    # 1265 / 1266
    g = complete_graph(3)
    add_edge!(g, 2, 2)
    @test @inferred(triangles(g)) == fill(1, 3)
end
