@testset "Parallel Maximal Independent Set" begin
    g0 = SimpleGraph(0)
    for g in testgraphs(g0)
        z = @inferred(LGVS.independent_set(g, LGVS.DistributedRandomSubset(4)))
        @test isempty(z)
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        z = @inferred(LGVS.independent_set(g, LGVS.DistributedRandomSubset(4)))
        @test (z == [1,])
    end

    add_edge!(g1, 1, 1)
    for g in testgraphs(g1)
        z = @inferred(LGVS.independent_set(g, LGVS.DistributedRandomSubset(4)))
        isempty(z)
    end

    g3 = SimpleGraph(LGGEN.Star(5))
    for g in testgraphs(g3)
        z = @inferred(LGVS.independent_set(g, LGVS.DistributedRandomSubset(4)))
        @test (length(z)== 1 || length(z)== 4)
    end

    g4 = SimpleGraph(LGGEN.Complete(5))
    for g in testgraphs(g4)
        z = @inferred(LGVS.independent_set(g, LGVS.DistributedRandomSubset(4)))
        @test length(z)== 1 #Exactly one vertex
    end

    g5 = SimpleGraph(LGGEN.Path(5))
    for g in testgraphs(g5)
        z = @inferred(LGVS.independent_set(g, LGVS.DistributedRandomSubset(4)))
        sort!(z)
        @test (z == [2, 4] || z == [2, 5] || z == [1, 3, 5] || z == [1, 4])
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for g in testgraphs(g5)
        z = @inferred(LGVS.independent_set(g, LGVS.DistributedRandomSubset(4)))
        sort!(z)
        @test (z == [4,] || z == [5,] || z == [1, 5] || z == [1, 4])
    end
end
