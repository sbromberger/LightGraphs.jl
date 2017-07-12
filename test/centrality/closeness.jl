@testset "Closeness" begin
    g5 = DiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)

    for g in testdigraphs(g5)
      y = @inferred(closeness_centrality(g; normalize=false))
      z = @inferred(closeness_centrality(g))
      py = @inferred(parallel_closeness_centrality(g; normalize=false))
      pz = @inferred(parallel_closeness_centrality(g))
      @test y == [0.75, 0.6666666666666666, 1.0, 0.0]
      @test z == [0.75, 0.4444444444444444, 0.3333333333333333, 0.0]
      @test py ≈ [0.75, 0.6666666666666666, 1.0, 0.0]
      @test pz ≈ [0.75, 0.4444444444444444, 0.3333333333333333, 0.0]
    end

    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a2 = DiGraph(adjmx2)
    for g in testdigraphs(a2)
      distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]
      c2 = [0.24390243902439027, 0.27027027027027023, 0.1724137931034483]
      y = @inferred(closeness_centrality(g, distmx2; normalize=false))
      z = @inferred(closeness_centrality(g, distmx2))
      py = @inferred(parallel_closeness_centrality(g, distmx2; normalize=false))
      pz = @inferred(parallel_closeness_centrality(g, distmx2))
      @test isapprox(y, c2)
      @test isapprox(z, c2)
      @test isapprox(py, c2)
      @test isapprox(pz, c2)
    end

    g5 = Graph(5)
    add_edge!(g5, 1, 2)
    for g in testgraphs(g5)
      z = @inferred(closeness_centrality(g))
      y = @inferred(parallel_closeness_centrality(g))
      @test z[1] == z[2] == 0.25
      @test z[3] == z[4] == z[5] == 0.0
      @test y[1] == y[2] == 0.25
      @test y[3] == y[4] == y[5] == 0.0
    end

    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    a1 = Graph(adjmx1)
    for g in testdigraphs(a2)
      distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
      c1 = [0.24390243902439027, 0.3225806451612903, 0.1923076923076923]
      y = @inferred(closeness_centrality(g, distmx1; normalize=false))
      z = @inferred(closeness_centrality(g, distmx1))
      py = @inferred(parallel_closeness_centrality(g, distmx1; normalize=false))
      pz = @inferred(parallel_closeness_centrality(g, distmx1))
      @test isapprox(y, c1)
      @test isapprox(z, c1)
      @test isapprox(py, c1)
      @test isapprox(pz, c1)
    end
end
