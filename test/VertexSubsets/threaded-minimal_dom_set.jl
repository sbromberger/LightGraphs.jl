@testset "Threaded Minimal Dominating Set" begin
    g0 = SimpleGraph(0)
    for g in testgraphs(g0)
       d = @inferred(LGVS.dominating_set(g, LGVS.ThreadedMinimalSubset(4)))
       @test isempty(d)
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        d = @inferred(LGVS.dominating_set(g, LGVS.ThreadedMinimalSubset(4)))
        @test (d == [1,])

        add_edge!(g, 1, 1)
        d = @inferred(LGVS.dominating_set(g, LGVS.ThreadedMinimalSubset(4)))
        @test (d == [1,])
    end

    g3 = SimpleGraph(LGGEN.Star(5))
    for g in testgraphs(g3)
        d = @inferred(LGVS.dominating_set(g, LGVS.ThreadedMinimalSubset(4)))
        @test (length(d)== 1 || (length(d)== 4 && minimum(d) > 1 ))
    end

    g4 = SimpleGraph(LGGEN.Complete(5))
    for g in testgraphs(g4)
        d = @inferred(LGVS.dominating_set(g, LGVS.ThreadedMinimalSubset(4)))
        @test length(d)== 1 #Exactly one vertex
    end

    g5 = SimpleGraph(LGGEN.Path(4))
    for g in testgraphs(g5)
        d = @inferred(LGVS.dominating_set(g, LGVS.ThreadedMinimalSubset(4)))
        sort!(d)
        @test (d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4])
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for g in testgraphs(g5)
        d = @inferred(LGVS.dominating_set(g, LGVS.ThreadedMinimalSubset(4)))
        sort!(d)
        @test (d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4])
    end
end
