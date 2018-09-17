@testset "Parallel.Random Vertex Cover" begin
  
    g3 = StarGraph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g3)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            @test (length(c)== 2 && (c[1] == 1 || c[2] == 1))
        end
    end
    
    g4 = CompleteGraph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g4)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            @test length(c)== 4 #All except one vertex 
        end
    end

    g5 = PathGraph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g5)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            sort!(c)
            @test (c == [1, 2, 3, 4] || c == [1, 2, 4, 5] || c == [2, 3, 4, 5])
        end
    end
end
