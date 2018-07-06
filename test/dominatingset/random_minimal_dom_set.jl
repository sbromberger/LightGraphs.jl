@testset "Random Minimal Dominating Set" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        d = @inferred(random_minimal_dominating_set(g, 2))
        @test (size(d)[1] == 1 || (size(d)[1] == 4 && minimum(d) > 1 ))

        d = @inferred(random_minimal_dominating_set(g, 2, parallel=true))
        @test (size(d)[1] == 1 || (size(d)[1] == 4 && minimum(d) > 1 ))
    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        d = @inferred(random_minimal_dominating_set(g, 2))
        @test size(d)[1] == 1 #Exactly one vertex 

        d = @inferred(random_minimal_dominating_set(g, 2, parallel=true))
        @test size(d)[1] == 1 
    end

    g5 = PathGraph(4)
    for g in testgraphs(g5)
        d = @inferred(random_minimal_dominating_set(g, 2))
        sort!(d)
        @test (d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4])

        d = @inferred(random_minimal_dominating_set(g, 2, parallel=true))
        sort!(d)
        @test (d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4])
    end
end
