@testset "Maximal Independent Set" begin
  
    g3 = StarGraph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g3)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel))
            @test (length(z)== 1 || length(z)== 4)
        end
    end
    
    g4 = CompleteGraph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g4)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel))
            @test length(z)== 1 #Exactly one vertex 
        end
    end

    g5 = PathGraph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g5)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel))
            sort!(z)
            @test (z == [2, 4] || z == [2, 5] || z == [1, 3, 5] || z == [1, 4])
        end
    end
end