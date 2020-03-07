@testset "Greedy Coloring" begin
  
    g3 = star_graph(10)

    for g in testgraphs(g3)
        for alg in [
                    LT.DegreeColoring(),
                    LT.RandomColoring(niter=5),
                    LT.FixedColoring(ordering=sortperm(vertices(g), rev=true))
                   ]
            C = @inferred(LT.greedy_color(g, alg))
            C2 = @inferred(LT.greedy_color(g))
            @test C.num_colors == C2.num_colors == 2
        end
    end
    
    g4 = path_graph(20)
    g5 = complete_graph(20)

    for graph in [g4, g5]
        for g in testgraphs(graph)
            for alg in [LT.DegreeColoring(), LT.RandomColoring(niter=5)]
                C = @inferred(LT.greedy_color(g, alg))
                @test C.num_colors <= maximum(degree(g))+1
                @test all(C.colors[src(e)] != C.colors[dst(e)] for e in edges(g))
            end
        end
    end
end

