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

@testset "Edge Triangle Count" begin
    g10 = SimpleGraph(SGGEN.Complete(5))
    @testset "$g" for g in testgraphs(g10)
        et_count = LCOM.edge_triangle_count(g, LCOM.DODG())
        for e in edges(g)
            @test et_count[e] == 3
        end
        et_count = LCOM.edge_triangle_count(g, LCOM.ThreadedDODG())
        for e in edges(g)
            @test et_count[e][] == 3
        end
    end
    rem_edge!(g10, 1, 2)
    @testset "$g" for g in testgraphs(g10)
        et_count = LCOM.edge_triangle_count(g, LCOM.DODG())
        for e in edges(g)
            x = min(src(e), dst(e))
            if x == 1 || x == 2
                @test et_count[e] == 2
            else
                @test et_count[e] == 3
            end
        end
        et_count = LCOM.edge_triangle_count(g, LCOM.ThreadedDODG())
        for e in edges(g)
            x = min(src(e), dst(e))
            if x == 1 || x == 2
                @test et_count[e][] == 2
            else
                @test et_count[e][] == 3
            end
        end
    end
end
