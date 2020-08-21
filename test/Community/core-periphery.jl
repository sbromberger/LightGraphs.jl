@testset "Core periphery" begin
    @testset "star graph core periphery" begin
        g10 = SimpleGraph(SGGEN.Star(10))
        @testset "$g" for g in testgraphs(g10)
            c = LCOM.core_periphery(g, LCOM.Degree())
            d = LCOM.core_periphery(g)
            @test c == d
            @test degree(g, 1) == 9
            @test c[1] == 1
            for i = 2:10
                @test c[i] == 2
            end
        end
    end

    @testset "blockdiag star graph core periphery" begin
        g10 = SimpleGraph(SGGEN.Star(10))
        g10 = blockdiag(g10, g10)
        add_edge!(g10, 1, 11)
        @testset "$g" for g in testgraphs(g10)
            c = @inferred(LCOM.core_periphery(g, LCOM.Degree()))
            @test c[1] == 1
            @test c[11] == 1
            for i = 2:10
                @test c[i] == 2
            end
            for i = 12:20
                @test c[i] == 2
            end
        end
    end
end
