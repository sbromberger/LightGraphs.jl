@testset "ThreadedCloseness" begin
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)

    for g in testdigraphs(g5)
        y = LCENT.centrality(g, LCENT.Closeness(normalize=false))
        ty = @inferred(LCENT.centrality(g, LCENT.ThreadedCloseness(normalize=false)))
        @test isapprox(y, ty)

        z = LCENT.centrality(g, LCENT.Closeness())
        tz = @inferred(LCENT.centrality(g, LCENT.ThreadedCloseness()))
        @test isapprox(z, tz)
    end

    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a2 = SimpleDiGraph(adjmx2)
    for g in testdigraphs(a2)
        distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]
        c2 = [0.24390243902439027, 0.27027027027027023, 0.1724137931034483]
        
        ty = LCENT.centrality(g, distmx2, LCENT.ThreadedCloseness(normalize=false))
        @test isapprox(ty, c2)
        
        tz = LCENT.centrality(g, distmx2, LCENT.ThreadedCloseness())
        @test isapprox(tz, c2)
    end

    g5 = SimpleGraph(5)
    add_edge!(g5, 1, 2)
    for g in testgraphs(g5)
        y = LCENT.centrality(g, LCENT.ThreadedCloseness())
        @test y[1] == y[2] == 0.25
        @test y[3] == y[4] == y[5] == 0.0
    end

    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    a1 = SimpleGraph(adjmx1)
    for g in testgraphs(a1)
        distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
        c1 = [0.24390243902439027, 0.3225806451612903, 0.1923076923076923]
        ty = @inferred(LCENT.centrality(g, distmx1, LCENT.ThreadedCloseness(normalize=false)))
        tz = @inferred(LCENT.centrality(g, distmx1, LCENT.ThreadedCloseness()))
        @test isapprox(ty, c1)
        @test isapprox(tz, c1)
    end
end
