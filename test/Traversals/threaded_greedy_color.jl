@testset "Threaded Greedy Coloring" begin
    g3 = star_graph(10)
    for g in testgraphs(g3)
        C = @inferred(LT.greedy_color(g, LT.ThreadedRandomColoring(niter=5))
        @test C.num_colors == 2
    end
    
    g4 = path_graph(20)
    g5 = complete_graph(20)

    for graph in [g4, g5]
        for g in testgraphs(graph)
            C = @inferred(LT.greedy_color(g, LT.ThreadedRandomColoring(niter=5)))
        
            @test C.num_colors <= maximum(degree(g))+1
            correct = true
            @test all(C.colors[src(e)] != C.colors[dst(e)] for in in edges(g))
        end
    end
end

