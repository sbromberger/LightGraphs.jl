@testset "Degree Dominating Set" begin

    g0 = SimpleGraph(0)
    for g in testgraphs(g0)
        d = @inferred(dominating_set(g, DegreeDominatingSet()))
        @test isempty(d)
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        d = @inferred(dominating_set(g, DegreeDominatingSet()))
        @test (d == [1,])
    end

    add_edge!(g1, 1, 1)
    for g in testgraphs(g1)
        d = @inferred(dominating_set(g, DegreeDominatingSet()))
        @test (d == [1,])
    end
    
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        @inferred(dominating_set(g, DegreeDominatingSet())) == [1,]
        @inferred(dominating_set(g, DegreeDominatingSet())) == [1,]
    end
    
    g4 = CompleteGraph(5)
    for g in testgraphs(g4)
        d = @inferred(dominating_set(g, DegreeDominatingSet()))
        @test length(d)== 1  
    end

    #PathGraph(5) with additional edge 2-5
    g5 = PathGraph(5)
    add_edge!(g5, 2, 5)
    for g in testgraphs(g5)
        d = @inferred(dominating_set(g, DegreeDominatingSet()))
        @test (length(d)== 2 && minimum(d) == 2)
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for g in testgraphs(g5)
        d = @inferred(dominating_set(g, DegreeDominatingSet()))
        @test (length(d)== 2 && minimum(d) == 2)
    end
end
