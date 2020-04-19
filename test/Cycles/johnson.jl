@testset "Cycles" begin
    completedg = SimpleDiGraph(SGGEN.Complete(4))
    pathdg = SimpleDiGraph(SGGEN.Path(5))
    triangle = SimpleGraph(SGGEN.RandomRegular(3, 2))
    quadrangle = SimpleGraph(SGGEN.RandomRegular(4, 2))
    pentagon = SimpleGraph(SGGEN.RandomRegular(5, 2))

    @testset "path digraph $g" for g in testgraphs(pathdg)
        @test LCY.max_simple_cycles(g) == LCY.max_simple_cycles(g, true) == LCY.max_simple_cycles(g, true, Tarjan()) == 0
        @test LCY.max_simple_cycles(g, false) == 84
        @test LCY.count_simple_cycles(g) == 0
        @test length(LCY.simple_cycles(g)) == 0
        @test isempty(LCY.simple_cycles(g)) == true
        @test isempty(LCY.simple_cycles(g, LCY.Johnson(iterative=true))) == true
        @test LCY.simple_cycles_length(g, LCY.Johnson()) == (zeros(5), 0)
        @test LCY.count_simple_cycles(g, LCY.Johnson(ceiling=10)) == 0
        @test isempty(LCY.simple_cycles(g, LCY.Johnson(iterative=true, ceiling=10))) == true
        @test LCY.simple_cycles_length(g, LCY.Johnson(ceiling=10)) == (zeros(5), 0)
    end

    @testset "max_simple_cycles(4)" begin
        @test LCY.max_simple_cycles(4) == 20
        @test LCY.max_simple_cycles(4, true) == 24
        @test LCY.ncycles_n_i(2, 1, true) == 2
        @test LCY.ncycles_n_i(2, 1) == 0
        @test LCY.ncycles_n_i(4, 2) == 6
    end

    @testset "complete digraph $g" for g in testgraphs(completedg)
        @test LCY.max_simple_cycles(g) == LCY.max_simple_cycles(g, true) == LCY.max_simple_cycles(g, true, Tarjan()) == 20
        @test length(LCY.simple_cycles(g)) == 20
        @test LCY.simple_cycles(g) == @inferred(LCY.simple_cycles(g, LCY.Johnson(iterative=true)))
        @test LCY.count_simple_cycles(g) == 20
        @test LCY.simple_cycles_length(g) == ([0, 6, 8, 6], 20)
        @test LCY.count_simple_cycles(g, LCY.Johnson(ceiling=10)) == 10
        @test LCY.simple_cycles_length(g, LCY.Johnson(ceiling=10))[2] == 10
    end

    @testset "triangle $g" for g in testgraphs(triangle)
        trianglelengths, triangletotal = LCY.simple_cycles_length(SimpleDiGraph(g))
        @test sum(trianglelengths) == triangletotal
    end

    @testset "quadrangle $g" for g in testgraphs(quadrangle)
        quadranglelengths, quadrangletotal = LCY.simple_cycles_length(SimpleDiGraph(g))
        @test sum(quadranglelengths) == quadrangletotal
        @test LCY.simple_cycles(SimpleDiGraph(g)) == @inferred(LCY.simple_cycles(SimpleDiGraph(g), LCY.Johnson(iterative=true)))
    end

    @testset "pentagon $g" for g in testgraphs(pentagon)
        pentagonlengths, pentagontotal = LCY.simple_cycles_length(SimpleDiGraph(g))
        @test sum(pentagonlengths) == pentagontotal
    end

    selfloopg = SimpleDiGraph([
        0 1 0 0;
        0 0 1 0;
        1 0 1 0;
        0 0 0 1;
    ])

    @testset "self loops $g" for g in testgraphs(selfloopg)
        cycles = LCY.simple_cycles(g)
        @test [3] in cycles
        @test [4] in cycles
        @test [1, 2, 3] in cycles || [2, 3, 1] in cycles || [3, 1, 2] in cycles
        @test length(cycles) == 3

        cycles2 = LCY.simple_cycles(g, LCY.Johnson(iterative=true))
        @test [3] in cycles2
        @test [4] in cycles2
        @test [1, 2, 3] in cycles2 || [2, 3, 1] in cycles2 || [3, 1, 2] in cycles2
        @test length(cycles2) == 3
    end
end
