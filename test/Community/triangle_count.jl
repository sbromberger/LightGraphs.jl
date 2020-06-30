@testset "Triangle Count" begin
    g10 = SimpleGraph(SGGEN.Complete(5))
    @testset "$g" for g in testgraphs(g10)
        @test LCOM.triangle_count(g, LCOM.DODG()) == 10
        @test LCOM.triangle_count(g, LCOM.ThreadedDODG()) == 10
    end
    rem_edge!(g10, 1, 2)
    @testset "$g" for g in testgraphs(g10)
        @test LCOM.triangle_count(g, LCOM.DODG()) == 7
        @test LCOM.triangle_count(g, LCOM.ThreadedDODG()) == 7
    end
end
