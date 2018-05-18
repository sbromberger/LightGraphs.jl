@testset "Random Vertex Cover" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        c = @inferred(random_vertex_cover(g, 2))
        @test (size(c)[1] == 2 && (c[1] == 1 || c[2] == 1))

        c = @inferred(random_vertex_cover(g, 2, parallel=true))
        @test (size(c)[1] == 2 && (c[1] == 1 || c[2] == 1))
    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        c = @inferred(random_vertex_cover(g, 2))
        @test size(c)[1] == 4 #All except one vertex 

        c = @inferred(random_vertex_cover(g, 2, parallel=true))
        @test size(c)[1] == 4 
    end

    g5 = PathGraph(5)
    for g in testgraphs(g5)
        c = @inferred(random_vertex_cover(g, 2))
        sort!(c)
        @test (c == [1, 2, 3, 4] || c == [1, 2, 4, 5] || c == [2, 3, 4, 5])

        c = @inferred(random_vertex_cover(g, 2, parallel=true))
        sort!(c)
        @test (c == [1, 2, 3, 4] || c == [1, 2, 4, 5] || c == [2, 3, 4, 5])
    end
end
