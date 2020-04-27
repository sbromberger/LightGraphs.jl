@testset "Eigenvector" begin
    g1 = SimpleGraph(SGGEN.House())
    g2 = SimpleDiGraph(SGGEN.Cycle(4))

    @testset "$g" for g in testgraphs(g1)
        y = @inferred(LCENT.centrality(g, LCENT.Eigenvector()))
        @test round.(y, digits=3) == round.([
            0.3577513877490464, 0.3577513877490464, 0.5298987782873977,
            0.5298987782873977, 0.4271328349194304
        ], digits=3)
    end
    @testset "$g" for g in testdigraphs(g2)
        y = @inferred(LCENT.centrality(g, LCENT.Eigenvector()))
        @test round.(y, digits=3) == round.([0.5, 0.5, 0.5, 0.5], digits=3)
    end
end
