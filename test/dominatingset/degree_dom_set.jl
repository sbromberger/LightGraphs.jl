@testset "Degree Dominating Set" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        d = @inferred(degree_dominating_set(g))
        @test size(d)[1] == 1 
    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        d = @inferred(degree_dominating_set(g))
        @test size(d)[1] == 1  
    end

    #PathGraph(5) with additional edge 2-5
    g5 = Graph([0 1 0 0 0; 1 0 1 0 1; 0 1 0 1 0; 0 0 1 0 1; 0 1 0 1 0])
    for g in testgraphs(g5)
        d = @inferred(degree_dominating_set(g))
        @test (size(d)[1] == 2 && minimum(d) == 2)
    end
end
