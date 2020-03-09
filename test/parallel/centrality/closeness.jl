@testset "Parallel.Closeness" begin
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)

    for g in testdigraphs(g5)
        dy = @inferred(Parallel.closeness_centrality(g; normalize=false, parallel=:distributed))
        @test dy ≈ [0.75, 0.6666666666666666, 1.0, 0.0]
        ty = @inferred(Parallel.closeness_centrality(g; normalize=false, parallel=:threads))
        @test ty ≈ [0.75, 0.6666666666666666, 1.0, 0.0]

        dz = @inferred(Parallel.closeness_centrality(g; parallel=:distributed))
        @test dz ≈ [0.75, 0.4444444444444444, 0.3333333333333333, 0.0]
        tz = @inferred(Parallel.closeness_centrality(g;  parallel=:threads))
        @test tz ≈ [0.75, 0.4444444444444444, 0.3333333333333333, 0.0]
    end

    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a2 = SimpleDiGraph(adjmx2)
    for g in testdigraphs(a2)
        distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]
        c2 = [0.24390243902439027, 0.27027027027027023, 0.1724137931034483]

        dy = @inferred(Parallel.closeness_centrality(g, distmx2; normalize=false, parallel=:distributed))
        @test isapprox(dy, c2)
        ty = @inferred(Parallel.closeness_centrality(g, distmx2; normalize=false, parallel=:threads))
        @test isapprox(ty, c2)

        dz = @inferred(Parallel.closeness_centrality(g, distmx2; parallel=:distributed))
        @test isapprox(dz, c2)
        tz = @inferred(Parallel.closeness_centrality(g, distmx2; parallel=:threads))
        @test isapprox(tz, c2)
    end

    g5 = SimpleGraph(5)
    add_edge!(g5, 1, 2)
    for g in testgraphs(g5)
        y = @inferred(Parallel.closeness_centrality(g; parallel=:distributed))
        @test y[1] == y[2] == 0.25
        @test y[3] == y[4] == y[5] == 0.0

        y = @inferred(Parallel.closeness_centrality(g; parallel=:threads))
        @test y[1] == y[2] == 0.25
        @test y[3] == y[4] == y[5] == 0.0
    end

    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    a1 = SimpleGraph(adjmx1)
    for g in testgraphs(a1)
        distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
        c1 = [0.24390243902439027, 0.3225806451612903, 0.1923076923076923]
        dy = @inferred(Parallel.closeness_centrality(g, distmx1; normalize=false, parallel=:distributed))
        dz = @inferred(Parallel.closeness_centrality(g, distmx1; parallel=:distributed))
        @test isapprox(dy, c1)
        @test isapprox(dz, c1)

        ty = @inferred(Parallel.closeness_centrality(g, distmx1; normalize=false, parallel=:threads))
        tz = @inferred(Parallel.closeness_centrality(g, distmx1; parallel=:threads))
        @test isapprox(ty, c1)
        @test isapprox(tz, c1)
    end
end
