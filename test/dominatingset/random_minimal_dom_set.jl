@testset "Random Minimal Dominating Set" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        d = @inferred(random_minimal_dominating_set(g))
        @test (length(d)== 1 || (length(d)== 4 && minimum(d) > 1 ))

        d = @inferred(parallel_random_minimal_dominating_set(g, 3))
        @test (length(d)== 1 || (length(d)== 4 && minimum(d) > 1 ))

    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        d = @inferred(random_minimal_dominating_set(g))
        @test length(d)== 1 #Exactly one vertex 

        d = @inferred(parallel_random_minimal_dominating_set(g, 4))
        @test length(d)== 1 
    end

    g5 = PathGraph(4)
    for g in testgraphs(g5)
        d = @inferred(random_minimal_dominating_set(g))
        sort!(d)
        @test (d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4])

        d = @inferred(parallel_random_minimal_dominating_set(g, 5))
        sort!(d)
        @test (d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4])
    end
end
