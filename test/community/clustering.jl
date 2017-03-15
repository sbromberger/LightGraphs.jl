@testset "Clustering" begin
    g10 = CompleteGraph(10)
    for g in (g10, Graph{UInt8}(g10), Graph{Int16}(g10))
      @test local_clustering_coefficient(g) == ones(10)
      @test global_clustering_coefficient(g) == 1
      @test local_clustering(g) == (fill(36, 10), fill(36, 10))
      @test triangles(g) == fill(36, 10)
      @test triangles(g, 1) == 36
    end
end
