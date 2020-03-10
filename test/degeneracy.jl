@testset "Decomposition" begin
    d = loadgraph(joinpath(testdir, "testdata", "graph-decomposition.jgz"))

    @testset "$g" for g in testgraphs(d)
        corenum = @inferred(core_number(g))
        @test corenum == [3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0]

        @testset "k-core" begin
            @test @inferred(k_core(g)) == k_core(g, corenum = corenum) == [1:8;]
            @test @inferred(k_core(g, 2)) == k_core(g, 2, corenum = corenum) == [1:16;]
            @test length(k_core(g, 4)) == 0
        end

        @testset "k-shell" begin
            @test @inferred(k_shell(g)) == k_shell(g, corenum = corenum) == [1:8;]
            @test @inferred(k_shell(g, 2)) == k_shell(g, 2, corenum = corenum) == [9:16;]
            @test length(k_shell(g, 4)) == 0
        end

        @testset "k-crust" begin
            @test @inferred(k_crust(g)) == k_crust(g, corenum = corenum) == [9:21;]
            @test @inferred(k_crust(g, 2)) == k_crust(g, 2, corenum = corenum) == [9:21;]
            @test @inferred(k_crust(g, 4, corenum = corenum)) == [1:21;]
        end

        @testset "k-corona" begin
            @test @inferred(k_corona(g, 1)) == k_corona(g, 1, corenum = corenum) == [17:20;]
            @test @inferred(k_corona(g, 2)) == [10, 12, 13, 14, 15, 16]
        end

        @testset "errors" begin
            add_edge!(g, 1, 1)
            @test_throws ArgumentError k_core(g)
            @test_throws ArgumentError k_shell(g)
            @test_throws ArgumentError k_crust(g)
            @test_throws ArgumentError k_corona(g, 1)
        end
    end
end
