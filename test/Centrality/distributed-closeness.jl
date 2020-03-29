@testset "DistributedCloseness" begin
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)

    for g in testdigraphs(g5)
        y = LCENT.centrality(g, LCENT.Closeness(normalize=false))
        dy = @inferred(LCENT.centrality(g, LCENT.DistributedCloseness(normalize=false)))
        @test isapprox(y, dy)

        z = LCENT.centrality(g, LCENT.Closeness())
        dz = @inferred(LCENT.centrality(g, LCENT.DistributedCloseness()))
        @test isapprox(z, dz)
    end

    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a2 = SimpleDiGraph(adjmx2)
    for g in testdigraphs(a2)
        distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]
        c2 = [0.24390243902439027, 0.27027027027027023, 0.1724137931034483]
        
        dy = LCENT.centrality(g, distmx2, LCENT.DistributedCloseness(normalize=false))
        @test isapprox(dy, c2)
        
        dz = LCENT.centrality(g, distmx2, LCENT.DistributedCloseness())
        @test isapprox(dz, c2)
    end

    g5 = SimpleGraph(5)
    add_edge!(g5, 1, 2)
    for g in testgraphs(g5)
        y = LCENT.centrality(g, LCENT.DistributedCloseness())
        @test y[1] == y[2] == 0.25
        @test y[3] == y[4] == y[5] == 0.0
    end

    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    a1 = SimpleGraph(adjmx1)
    for g in testgraphs(a1)
        distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
        c1 = [0.24390243902439027, 0.3225806451612903, 0.1923076923076923]
        dy = @inferred(LCENT.centrality(g, distmx1, LCENT.DistributedCloseness(normalize=false)))
        dz = @inferred(LCENT.centrality(g, distmx1, LCENT.DistributedCloseness()))
        @test isapprox(dy, c1)
        @test isapprox(dz, c1)
    end
end
