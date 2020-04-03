@testset "Cycles" begin
    completedg = complete_digraph(4)
    pathdg = path_digraph(5)
    triangle = random_regular_graph(3, 2)
    quadrangle = random_regular_graph(4, 2)
    pentagon = random_regular_graph(5, 2)

    @testset "path digraph" for g in testgraphs(pathdg)
        @test LCY.max_simple_cycles(g) == 0
        @test LCY.max_simple_cycles(g, false) == 84
        @test LCY.count_simple_cycles(g) == 0
        @test LCY.length(simple_cycles(g)) == 0
        @test LCY.isempty(simple_cycles(g)) == true
        @test LCY.isempty(simple_cycles(g, LCY.Johnson(iterative=true))) == true
        @test LCY.simple_cycles_length(g, LCY.Johnson()) == (zeros(5), 0)
        @test LCY.count_simple_cycles(g, LCY.Johnson(ceiling=10)) == 0
        @test LCY.isempty(simple_cycles(g, LCY.Johnson(iterative=true, ceiling=10))) == true
        @test LCY.simple_cycles_length(g, LCY.Johnson(ceiling=10)) == (zeros(5), 0)
    end

    @testset "max_simple_cycles(4)" begin
        @test max_simple_cycles(4) == 20
    end

    @testset "complete digraph" for g in testgraphs(completedg)
        @test LCY.max_simple_cycles(g) == 20
        @test LCY.length(simple_cycles(g)) == 20
        @test LCY.simple_cycles(g) == @inferred(LCY.simple_cycles(g, LCY.Johnson(iterative=true)))
        @test LCY.count_simple_cycles(g) == 20
        @test LCY.simple_cycles_length(g) == ([0, 6, 8, 6], 20)
        @test LCY.count_simple_cycles(g, LCY.Johnson(ceiling=10)) == 10
        @test LCY.simple_cycles_length(g, LCY.Johnson(ceiling=10))[2] == 10
    end

    @testset "triangle" for g in testgraphs(triangle)
        trianglelengths, triangletotal = LCY.simple_cycles_length(DiGraph(g))
        @test sum(trianglelengths) == triangletotal
    end

    @testset "quadrangle" for g in testgraphs(quadrangle)
        quadranglelengths, quadrangletotal = LCY.simple_cycles_length(DiGraph(g))
        @test sum(quadranglelengths) == quadrangletotal
        @test LCY.simple_cycles(DiGraph(g)) == @inferred(LCY.simple_cycles(DiGraph(g), LCY.Johnson(iterative=true)))
    end

    @testset "pentagon" for g in testgraphs(pentagon)
        pentagonlengths, pentagontotal = LCY.simple_cycles_length(DiGraph(g))
        @test sum(pentagonlengths) == pentagontotal
    end

    selfloopg = DiGraph([
        0 1 0 0;
        0 0 1 0;
        1 0 1 0;
        0 0 0 1;
    ])

    @testset "self loops" for g in testgraphs(selfloopg)
        cycles = simple_cycles(g)
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
