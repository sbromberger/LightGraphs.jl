@testset "Limited Length Cycles" begin
    completedg = SimpleDiGraph(SGGEN.Complete(4))
    pathdg = SimpleDiGraph(SGGEN.Path(5))
    cycledg = SimpleDiGraph(SGGEN.Cycle(5))

    @testset "complete digraph $g" for g in testgraphs(completedg)
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(0))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(1))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(2))) == 6
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(3))) == 14
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(4))) == 20
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(4, ceiling=10))) == 10
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(4, typemax(Int)))) == 20
    end

    @testset "path digraph $g" for g in testgraphs(pathdg)
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(1))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(2))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(3))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(4))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(5))) == 0
    end

    @testset "cycle digraph $g" for g in testgraphs(cycledg)
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(1))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(2))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(3))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(4))) == 0
        @test length(LCY.simple_cycles(g, LCY.LimitedLength(5))) == 1
    end

    @testset "self loops" begin
        selfloopg = SimpleDiGraph([
            0 1 0 0;
            0 0 1 0;
            1 0 1 0;
            0 0 0 1;
        ])
        cycles = LCY.simple_cycles(selfloopg, LCY.LimitedLength(nv(selfloopg)))
        @test [3] in cycles
        @test [4] in cycles
        @test [1, 2, 3] in cycles || [2, 3, 1] in cycles || [3, 1, 2] in cycles
        @test length(cycles) == 3
    end

    @testset "octahedral graph" begin
        octag = SimpleGraph(SGGEN.Octahedral())
        octadg = SimpleDiGraph(octag)
        octalengths, _ = LCY.simple_cycles_length(octadg)
        for k = 1:6
            @test sum(octalengths[1:k]) == length(LCY.simple_cycles(octag, LCY.LimitedLength(k)))
            @test sum(octalengths[1:k]) == length(LCY.simple_cycles(octadg, LCY.LimitedLength(k)))
        end
    end
end
