@testset "Random Independent Set" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        z = @inferred(random_maximal_independent_set(g, 2))
        @test (size(z)[1] == 1 || size(z)[1] == 4)

        z = @inferred(random_maximal_independent_set(g, 2, parallel=true))
        @test (size(z)[1] == 1 || size(z)[1] == 4)
    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        z = @inferred(random_maximal_independent_set(g, 2))
        @test size(z)[1] == 1 #Exactly one vertex 

        z = @inferred(random_maximal_independent_set(g, 2, parallel=true))
        @test size(z)[1] == 1 
    end

    g5 = PathGraph(5)
    for g in testgraphs(g5)
        z = @inferred(random_maximal_independent_set(g, 2))
        sort!(z)
        @test (z == [2, 4] || z == [2, 5] || z == [1, 3, 5] || z == [1, 4])

        z = @inferred(random_maximal_independent_set(g, 2, parallel=true))
        sort!(z)
        @test (z == [2, 4] || z == [2, 5] || z == [1, 3, 5] || z == [1, 4])
    end
end
