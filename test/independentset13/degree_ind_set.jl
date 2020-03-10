@testset "Degree Independent Set" begin

    g0 = SimpleGraph(0)
    @testset "$g" for g in testgraphs(g0)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test isempty(c)
    end

    g1 = SimpleGraph(1)
    @testset "$g" for g in testgraphs(g1)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test (c == [1,])
    end

    add_edge!(g1, 1, 1)
    @testset "$g" for g in testgraphs(g1)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test isempty(c)
    end

    g3 = star_graph(5)
    @testset "$g" for g in testgraphs(g3)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test sort(c) == [2, 3, 4, 5]
    end

    g4 = complete_graph(5)
    @testset "$g" for g in testgraphs(g4)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test length(c)== 1 #Exactly one vertex
    end

    #path_graph(5) with additional edge 2-5
    g5 = path_graph(5)
    add_edge!(g5, 2, 5)
    @testset "$g" for g in testgraphs(g5)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test sort(c) == [1, 3, 5]
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    @testset "$g" for g in testgraphs(g5)
        c = @inferred(independent_set(g, DegreeIndependentSet()))
        @test sort(c) == [1, 5]
    end
end
