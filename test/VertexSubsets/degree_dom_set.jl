@testset "Degree Dominating Set" begin

    g0 = SimpleGraph(0)
    for g in testgraphs(g0)
        d = @inferred(LGVS.dominating_set(g, LGVS.DegreeSubset()))
        @test isempty(d)
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        d = @inferred(LGVS.dominating_set(g, LGVS.DegreeSubset()))
        @test (d == [1,])
    end

    add_edge!(g1, 1, 1)
    for g in testgraphs(g1)
        d = @inferred(LGVS.dominating_set(g, LGVS.DegreeSubset()))
        @test (d == [1,])
    end

    g3 = SimpleGraph(LGGEN.Star(5))
    for g in testgraphs(g1)
        d = @inferred(LGVS.dominating_set(g, LGVS.DegreeSubset()))
        @test (d == [1,])
    end

    g4 = SimpleGraph(LGGEN.Complete(5))
    for g in testgraphs(g4)
        d = @inferred(LGVS.dominating_set(g, LGVS.DegreeSubset()))
        @test length(d)== 1
    end

    #path_graph(5) with additional edge 2-5
    g5 = SimpleGraph(LGGEN.Path(5))
    add_edge!(g5, 2, 5)
    for g in testgraphs(g5)
        d = @inferred(LGVS.dominating_set(g, LGVS.DegreeSubset()))
        @test (length(d)== 2 && minimum(d) == 2)
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for g in testgraphs(g5)
        d = @inferred(LGVS.dominating_set(g, LGVS.DegreeSubset()))
        @test (length(d)== 2 && minimum(d) == 2)
    end
end
