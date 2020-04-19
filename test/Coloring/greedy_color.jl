@testset "Greedy Coloring" begin

    g3 = star_graph(10)

    @testset "$g" for g in testgraphs(g3)
        for alg in [
                    LCOL.DegreeColoring(),
                    LCOL.RandomColoring(niter=5),
                    LCOL.FixedColoring(ordering=sortperm(vertices(g), rev=true))
                   ]
            C = @inferred(LCOL.greedy_color(g, alg))
            C2 = @inferred(LCOL.greedy_color(g))
            @test C.num_colors == C2.num_colors == 2
        end
    end

    g4 = path_graph(20)
    g5 = complete_graph(20)

    for graph in [g4, g5]
        @testset "$g" for g in testgraphs(graph)
            for alg in [LCOL.DegreeColoring(), LCOL.RandomColoring(niter=5)]
                C = @inferred(LCOL.greedy_color(g, alg))
                @test C.num_colors <= maximum(degree(g))+1
                @test all(C.colors[src(e)] != C.colors[dst(e)] for e in edges(g))
            end
        end
    end
end
