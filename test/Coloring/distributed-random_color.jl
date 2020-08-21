@testset "Distributed Random Coloring" begin
    g3 = SimpleGraph(SGGEN.Star(10))
    for g in testgraphs(g3)
        C = @inferred(LCOL.color(g, LCOL.DistributedRandomColoring(niter=5)))
        @test C.num_colors == 2
    end

    g4 = SimpleGraph(SGGEN.Path(20))
    g5 = SimpleGraph(SGGEN.Complete(20))

    for graph in [g4, g5]
        @testset "$g" for g in testgraphs(graph)
            C = @inferred(LCOL.color(g, LCOL.DistributedRandomColoring(niter=5)))

            @test C.num_colors <= maximum(degree(g))+1
            correct = true
            @test all(C.colors[src(e)] != C.colors[dst(e)] for e in edges(g))
        end
    end
end
