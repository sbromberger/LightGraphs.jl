@testset "Jones Plassmann" begin
    g3 = SimpleGraph(SGGEN.Star(10))
    g4 = SimpleGraph(SGGEN.Path(20))
    g5 = SimpleGraph(SGGEN.Complete(20))

    for graph in [g3, g4, g5]
        @testset "$g" for g in testgraphs(graph)
            C = @inferred(LCOL.color(g, LCOL.JonesPlassmann()))
            @test all(C.colors[src(e)] != C.colors[dst(e)] for e in edges(g))
        end
    end
end
