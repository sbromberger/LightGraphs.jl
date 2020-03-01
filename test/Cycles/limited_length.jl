@testset "Limited Length Cycles" begin
    completedg = complete_digraph(4)
    pathdg = path_digraph(5)
    cycledg = cycle_digraph(5)

    @testset "complete digraph" for g in testgraphs(completedg)
        @test length(simple_cycles(g, LimitedLength(0))) == 0
        @test length(simple_cycles(g, LimitedLength(1))) == 0
        @test length(simple_cycles(g, LimitedLength(2))) == 6
        @test length(simple_cycles(g, LimitedLength(3))) == 14
        @test length(simple_cycles(g, LimitedLength(4))) == 20
        @test length(simple_cycles(g, LimitedLength(4, 10))) == 10
        @test length(simple_cycles(g, LimitedLength(4, typemax(Int)))) == 20
    end

    @testset "path digraph" for g in testgraphs(pathdg)
        @test length(simple_cycles(g, LimitedLength(1))) == 0
        @test length(simple_cycles(g, LimitedLength(2))) == 0
        @test length(simple_cycles(g, LimitedLength(3))) == 0
        @test length(simple_cycles(g, LimitedLength(4))) == 0
        @test length(simple_cycles(g, LimitedLength(5))) == 0
    end

    @testset "cycle digraph" for g in testgraphs(cycledg)
        @test length(simple_cycles(g, LimitedLength(1))) == 0
        @test length(simple_cycles(g, LimitedLength(2))) == 0
        @test length(simple_cycles(g, LimitedLength(3))) == 0
        @test length(simple_cycles(g, LimitedLength(4))) == 0
        @test length(simple_cycles(g, LimitedLength(5))) == 1
    end

    @testset "self loops" begin
        selfloopg = DiGraph([
            0 1 0 0;
            0 0 1 0;
            1 0 1 0;
            0 0 0 1;
        ])
        cycles = simple_cycles(selfloopg, LimitedLength(nv(selfloopg)))
        @test [3] in cycles
        @test [4] in cycles
        @test [1, 2, 3] in cycles || [2, 3, 1] in cycles || [3, 1, 2] in cycles
        @test length(cycles) == 3
    end

    @testset "octahedral graph" begin
        octag = smallgraph(:octahedral)
        octadg = DiGraph(octag)
        octalengths, _ = simple_cycles_length(octadg)
        for k = 1:6
            @test sum(octalengths[1:k]) == length(simple_cycles(octag, LimitedLength(k)))
            @test sum(octalengths[1:k]) == length(simple_cycles(octadg, LimitedLength(k)))
        end
    end
end
