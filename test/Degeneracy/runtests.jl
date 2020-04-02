const LD = LightGraphs.Degeneracy

@testset "Decomposition" begin
    d = loadgraph(joinpath(testdir, "testdata", "graph-decomposition.jgz"))

    @testset "$g" for g in testlargegraphs(d)
        @testset "core_number" begin
            corenum = @inferred(LD.core_number(g))
            threaded_corenum = @inferred(LD.core_number(g, LD.ThreadedBatagelj()))
            threaded_corenum_05 = @inferred(LD.core_number(g, LD.ThreadedBatagelj(frac=0.5)))
            @test corenum == threaded_corenum == threaded_corenum_05 ==
                [3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0]
        end

        corenum = @inferred(LD.core_number(g))
        @testset "k-core" begin
            @test   @inferred(LD.decompose(g, LD.KCore())) == LD.decompose(g, LD.KCore(), corenum) == [1:8;]
            @test   @inferred(LD.decompose(g, LD.KCore(2))) ==
                    @inferred(LD.decompose(g, LD.KCore(k=2))) ==
                    @inferred(LD.decompose(g, LD.KCore(2), corenum)) == [1:16;]
            @test length(LD.decompose(g, LD.KCore(4))) == 0
        end

        @testset "k-shell" begin
            @test   @inferred(LD.decompose(g, LD.KShell())) == LD.decompose(g, LD.KShell(), corenum) == [1:8;]
            @test   @inferred(LD.decompose(g, LD.KShell(2))) ==
                    @inferred(LD.decompose(g, LD.KShell(k=2))) ==
                    @inferred(LD.decompose(g, LD.KShell(2), corenum)) == [9:16;]
            @test length(LD.decompose(g, LD.KShell(4))) == 0
        end

        @testset "k-crust" begin
            @test   @inferred(LD.decompose(g, LD.KCrust())) == LD.decompose(g, LD.KCrust(), corenum) == [9:21;]
            @test   @inferred(LD.decompose(g, LD.KCrust(2))) ==
                    @inferred(LD.decompose(g, LD.KCrust(k=2))) ==
                    @inferred(LD.decompose(g, LD.KCrust(2), corenum)) == [9:21;]
            @test   @inferred(LD.decompose(g, LD.KCrust(4))) ==
                    @inferred(LD.decompose(g, LD.KCrust(k=4), corenum)) == [1:21;]
        end

        @testset "k-corona" begin
            @test   @inferred(LD.decompose(g, LD.KCorona(1))) ==
                    @inferred(LD.decompose(g, LD.KCorona(k=1))) ==
                    @inferred(LD.decompose(g, LD.KCorona(1), corenum)) == [17:20;]
            @test   @inferred(LD.decompose(g, LD.KCorona(2))) ==
                    @inferred(LD.decompose(g, LD.KCorona(k=2))) ==
                    @inferred(LD.decompose(g, LD.KCorona(2), corenum)) == [10, 12, 13, 14, 15, 16]
        end

        @testset "errors" begin
            add_edge!(g, 1, 1)
            for t in [LD.KCore(), LD.KShell(), LD.KCrust(), LD.KCorona(1)]
                @test_throws ArgumentError LD.decompose(g, t)
            end
            for t in [LD.Batagelj(), LD.ThreadedBatagelj(), LD.ThreadedBatagelj(frac=0.5)]
                @test_throws ArgumentError LD.core_number(g, t)
            end
        end
    end
end
