@testset "Degree Vertex Cover" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        c = @inferred(degree_vertex_cover(g))
        @test c == [1,]
    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        c = @inferred(degree_vertex_cover(g))
        @test length(c)== 4 #All except one vertex 
    end

    #PathGraph(5) with additional edge 2-5
    g5 = Graph([0 1 0 0 0; 1 0 1 0 1; 0 1 0 1 0; 0 0 1 0 1; 0 1 0 1 0])
    for g in testgraphs(g5)
        c = @inferred(degree_vertex_cover(g))
        @test sort(c) == [2, 4]
    end
end
