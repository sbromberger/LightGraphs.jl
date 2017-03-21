@testset "Core periphery" begin
    g10 = StarGraph(10)
    for g in testgraphs(g10)
        c = core_periphery_deg(g)
        @test @inferred(degree(g, 1)) == 9
        @test c[1] == 1
        for i=2:10
            @test c[i] == 2
        end
    end

    g10 = StarGraph(10)
    g10 = blkdiag(g10,g10)
    add_edge!(g10, 1, 11)
    for g in testgraphs(g10)
        c = @inferred(core_periphery_deg(g))
        @test c[1] == 1
        @test c[11] == 1
        for i=2:10
            @test c[i] == 2
        end
        for i=12:20
            @test c[i] == 2
        end
    end
end
