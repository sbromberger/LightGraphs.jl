@testset "Degree Independent Set" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test sort(c) == [2, 3, 4, 5]
    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test length(c)== 1 #Exactly one vertex 
    end

    #PathGraph(5) with additional edge 2-5
    g5 = Graph([0 1 0 0 0; 1 0 1 0 1; 0 1 0 1 0; 0 0 1 0 1; 0 1 0 1 0])
    for g in testgraphs(g5)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test sort(c) == [1, 3, 5]
    end
end