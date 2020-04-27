@testset "Clustering" begin
    g10 = SimpleGraph(SGGEN.Complete(10))
    @testset "$g" for g in testgraphs(g10)
        @test @inferred(LCOM.clustering_coefficient(g, LCOM.Local(1))) == 1.0
        @test @inferred(LCOM.clustering_coefficient(g, LCOM.Local(vertices(g)))) == 
            LCOM.clustering_coefficient(g, LCOM.Local()) == ones(10)
        @test @inferred(LCOM.clustering_coefficient(g, LCOM.Global())) == 
            LCOM.clustering_coefficient(g) == 1.0
        @test @inferred(LCOM.clustering(g, LCOM.Local())) == (fill(36, 10), fill(36, 10))
        @test @inferred(LCOM.triangles(g)) == fill(36, 10)
        @test @inferred(LCOM.triangles(g, 1)) == 36
    end
    # 1265 / 1266
    g = SimpleGraph(SGGEN.Complete(3))
    add_edge!(g, 2, 2)
    @test @inferred(LCOM.triangles(g)) == fill(1, 3)
end
