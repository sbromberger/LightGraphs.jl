@testset "Triangle Count" begin
    g10 = SimpleGraph(SGGEN.Complete(5))
    @testset "$g" for g in testgraphs(g10)
        @test LCOM.triangle_count(g) == 10
        @test LCOM.triangle_count(g, LCOM.ThreadedTriangleCount()) == 10
    end
    rem_edge!(g10, 1, 2)
    @testset "$g" for g in testgraphs(g10)
        @test LCOM.triangle_count(g) == 7
        @test LCOM.triangle_count(g, LCOM.ThreadedTriangleCount()) == 7
    end
end
