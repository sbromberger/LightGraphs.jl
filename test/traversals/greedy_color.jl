@testset "Greedy Coloring" begin
  
    g3 = StarGraph(10)

    for g in testgraphs(g3)
        for op_sort in (true, false), op_parallel in (true, false)
            C = @inferred(greedy_color(g, reps=5, sort_degree=op_sort, parallel=op_parallel))
            @test C.num_colors == 2
        end
    end
    
    g4 = PathGraph(20)
    g5 = CompleteGraph(20)

    for graph in [g4, g5]
        for g in testgraphs(graph)
            for op_sort in (true, false), op_parallel in (true, false)
                C = @inferred(greedy_color(g, reps=5, sort_degree=op_sort, parallel=op_parallel))
        
                @test C.num_colors <= maximum(degree(g))+1
                correct = true
                for e in edges(g)
                    C.colors[src(e)] == C.colors[dst(e)] && (correct = false)
                end

                @test correct
            end
        end
    end

end

